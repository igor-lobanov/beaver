package Beaver::Model::SQLite;

use Mojo::Base 'Beaver::Model';
use Carp qw(croak);

use Data::Dumper;

has [qw(sql)];
has typemap => sub {{
    integer     => 'INTEGER',
    text        => 'TEXT',
    real        => 'REAL',
    blob        => 'BLOB',
    int         => 'INTEGER',
    date        => 'TEXT',
    datetime    => 'TEXT',
    string      => 'TEXT',
}};

# single connection
my $sql;

sub init {
    my $m = shift;
    $m->sql($sql ||= $m->app->connect($m->backend));
    $m->_update_schema;
    $m;
}

sub item {
    my ($m, $id) = @_;
    $id ||= 0;
    $id = $m->c->id if !$id && $m->c->entity eq $m->entity;
    return undef if !$id;
    $m->sql->db->query(qq{
        SELECT * FROM @{[ $m->entity ]} WHERE id = ?
    }, $id)->hash;
}

# $m->list({
#   portion => 25,
#   start   => 100,
#   order   => [
#       {field1 => 'ASC'},
#       {field2 => 'DESC'}
#   ],
# }, {
#   -href => sub { "/list/$_[0]->{id}" }
# })
sub list {
    my ($m, $list, $add) = @_;
    $list ||= {};
    $list->{portion} ||= 10;
    $list->{start} ||= 0;
    my $rows = $m->sql->db->query(qq{
        SELECT * FROM @{[ $m->entity ]} @{[
            $list->{order} ? $m->_order_by($list->{order}) : ''
        ]} LIMIT ? OFFSET ?
    }, $list->{portion}, $list->{start})->hashes;
    $add ? $rows->each(sub {my ($e) = @_; $e->{$_} = $add->{$_}->($e) for keys %$add}) : $rows;
}

sub _order_by {
    my ($m, $fields) = @_;
    my @order;
    if (ref $fields eq 'HASH') {
        for my $f (keys %$fields) {
            next if $$fields{$f} !~ /^asc|desc$/i;
            push @order, $f . ' ' . uc($$fields{$f});
        }
    }
    elsif (ref $fields eq 'ARRAY') {
        for my $f (@$fields) {
            if (ref $f eq 'HASH') {
                push @order, map { $_ . ' ' . uc($$f{$_}) } grep {$$f{$_} =~ /^asc|desc$/i} keys %$f;
            }
            elsif (!ref $f) {
                push @order, $f;
            }
        }
    }
    elsif (!ref $fields) {
        push @order, $fields;
    }
    ~~@order ? 'ORDER BY ' . join(', ', @order) : '';
}

sub create {
    my ($m, $data) = (shift, _hash(@_));
    $$data{fake} //= \q{ABS(RANDOM())};
    # model check fiedls must be added
    $m->sql->db->insert($m->entity, $data)->last_insert_id;
}

sub update {
    my ($m, $data) = (shift, _hash(@_));
    $$data{fake} ||= 0;
    $$data{id} ||= 0;
    $$data{id} = $m->c->id if !$$data{id} && $m->c->entity eq $m->entity;
    return undef if !$$data{id};
    # model check fields must be updated
    $m->sql->db->update($m->entity, { map { $_ => $$data{$_} } grep {$_ ne 'id'} keys %$data }, {id => $$data{id}});
}

sub _hash { ref $_[0] eq 'HASH' ? $_[0] : @_%2 == 0 ? { @_ } : { @_, undef } }

sub _update_schema {
    my ($m) = @_;
    state $done = 0;
    return if $done;

    # TODO lock schema update 
    eval {
        my $info = $m->sql->db->select('_beaver_schema', ['version'], {entity => $m->entity})->hash || {};
        $info->{version} ||= 0;

        if ($info->{version} == 0) {
            # create table according schema
            my $struct = $m->schema->get || {};
            my @fields;
            for my $field (sort keys %$struct) {
                push @fields, sprintf('%s %s',
                    $field,
                    $struct->{$field}{type}
                );
            }
            $m->sql->db->query(qq{
                CREATE TABLE @{[ $m->entity ]} (@{[ join(',', @fields) ]})
            });
            $m->sql->db->insert('_beaver_schema', {entity => $m->entity, version => $m->schema->version});
        }
        elsif ($info->{version} < $m->schema->version) {
            # compare current schema with new one
            my $fields = $m->sql->db->query('PRAGMA table_info(' . $m->entity . ')')->hashes;
            my $current = {};
            $current->{ $_->{name} } = {
                type    => $_->{type},
                notnull => $_->{notnull},
                default => eval "$_->{dflt_value}",
            } for @$fields;

            my $schema = $m->schema->get || {};
            my (@add, $modify);
            for my $name (keys %$schema) {
                if (!exists $$current{$name}) {
                    # ADD COLUMN
                    $$schema{$name}{default} //= ($$schema{$name}{type} eq 'text' ? '' : 0) if $$schema{$name}{notnull};
                    push @add, {
                        name => $name,
                        map { ($_ => $$schema{$name}{$_}) x!! defined $$schema{$name}{$_} } qw(type notnull default),
                    };
                }
                elsif (
                    (lc($$current{$name}{type}) ne lc($m->typemap->{ lc $$schema{$name}{type} }))
                    || (!!$$current{$name}{notnull} != !!$$schema{$name}{notnull})
                    || ($$current{$name}{default}//'' ne $$schema{$name}{default}//'')
                ) {
                    # MODIFY COLUMN (SQLite3 - create new table, copy data, drop old table, rename new table)
                    # ADD COLUMN will not be used if we have modified fields
                    $modify = 1;
                    last;
                }
            }

            if ($modify) {
                # create table from old schema with overriding and adding field definitions
                my $struct = { %$current, %{ $m->schema->get || {} } };
                $struct->{$_}{default} //= ($struct->{$_}{type} eq 'text' ? '' : 0) for grep { $struct->{$_}{notnull} } keys %$struct;
                my @copy = keys %$current;
                my @copy_values = map {
                    $struct->{$_}{notnull}
                    ? (
                        $struct->{$_}{type} eq 'text'
                        ? "COALESCE($_, '$struct->{$_}{default}')"
                        : "COALESCE($_, $struct->{$_}{default})"
                    )
                    : $_
                } @copy;
                my @fields;
                for my $field (sort keys %$struct) {
                    push @fields, join(' ',
                        $field,
                        $struct->{$field}{type},
                        ($struct->{$field}{notnull} ? 'NOT NULL' : ()),
                        (
                            defined($struct->{$field}{default})
                            ? (
                                $struct->{$field}{type} eq 'text'
                                ? "DEFAULT '$struct->{$field}{default}'"
                                : "DEFAULT $struct->{$field}{default}"
                            )
                            : ()
                        ),
                    );
                }
                $m->sql->db->query(qq{
                    CREATE TABLE _new_@{[ $m->entity ]} (@{[ join(', ', @fields) ]})
                });
                $m->sql->db->query(qq{
                    INSERT INTO _new_@{[ $m->entity ]} (@{[ join(', ', @copy) ]})
                    SELECT @{[ join(', ', @copy_values) ]} FROM @{[ $m->entity ]}
                });
                $m->sql->db->query(qq{ DROP TABLE @{[ $m->entity ]} });
                $m->sql->db->query(qq{ ALTER TABLE _new_@{[ $m->entity ]} RENAME TO @{[ $m->entity ]} });
            }
            elsif (@add) {
                for (@add) {
                    $m->sql->db->query(qq{
                        ALTER TABLE @{[ $m->entity ]}
                        ADD COLUMN @{[ $_->{name} ]} @{[ $m->typemap->{ lc $_->{type} } ]}
                        @{[ $_->{notnull} ? 'NOT NULL' : '' ]}
                        @{[ defined($_->{default}) ? (
                            $_->{type} eq 'text' ? "DEFAULT '$_->{default}'" : "DEFAULT $_->{default}"
                        ) : '' ]}
                    });
                }
            }

            $m->sql->db->update('_beaver_schema', {version => $m->schema->version}, {entity => $m->entity});

        }
    };

    die $@ if $@;

    $done = 1;
}

1;

