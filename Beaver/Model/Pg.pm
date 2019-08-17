package Beaver::Model::Pg;

use Mojo::Base 'Beaver::Model';
use Beaver::Model::Result;

has [qw(backend pg db sql)];
use Data::Dumper;

my $pg;

sub init {
    my $m = shift;
    $m->pg($pg ||= $m->app->connect($m->backend));
    $m->db($pg->db);
    $m->sql($pg->abstract);
    $m;
}

sub item {
    my $m = shift;
    my ($id, $opts) = $m->_id_opts(@_);
    $id = $m->c->id if !$id && $m->c->entity eq $m->entity;
    return undef if !$id;

    my $return = new Beaver::Model::Result;
    $return->row(
        $m->db->query(qq{
            SELECT *
            FROM @{[ $m->entity ]}
            WHERE id = ? AND (fake = 0 OR fake = ?)
        }, $id, $m->c->sid)->hash
    );
    $return->vocs(
        { map { $_ => $m->c->load_model($_)->list({sort => 'label', nolimit => 1})->rows } ref $$opts{add_vocs} ? @{ $$opts{add_vocs} } : $m->vocs->each }
    ) if $$opts{add_vocs};

    return $return;
}

sub list {
    my $m = shift;
    my $opts = $m->_opts(@_);
    my $table = $m->entity;
    my $sort = $$opts{sort} ? $m->_order_by($opts->{sort}) : '';
    my $limit = $$opts{nolimit} ? '' : sprintf('LIMIT %i OFFSET %i', ($$opts{portion}||=10)+0, ($$opts{start}||=0)+0);
    my @fields = ref $$opts{fields} ? map {"$table.$_"} @{ $$opts{fields} } : "$table.*";
    my @joins;
    if ($$opts{join_vocs}) {
        for my $field (grep {$_->{vocabulary}} map {$m->field($_)} keys %{ $$opts{join_vocs} }) {
            push @joins, "LEFT JOIN $$field{vocabulary} ON $table.$$field{name} = $$field{vocabulary}.id";
            push @fields, "$$field{vocabulary}.label AS $$opts{join_vocs}{$$field{name}}";
        }
    }
    my $joins = join(' ', @joins);
    my $fields = join(', ', @fields);

    my $return = new Beaver::Model::Result;
    $return->rows(
        $m->db->query(qq{
            SELECT $fields
            FROM $table $joins
            WHERE $table.fake = 0
            $sort
            $limit
        })->hashes
    );
    $return->rows->each(sub {
        my ($e) = @_;
        $e->{$_} = $$opts{add_fields}{$_}->($e) for keys %{$$opts{add_fields}}
    }) if $$opts{add_fields};

    $return->count(
        $m->db->query(qq{ SELECT COUNT(*) AS count FROM $table WHERE fake = 0 })->hash->{count}
    ) if $$opts{count};

    $return->vocs({
        map {
            $_ => $m->c->load_model($_)->list({sort => 'label', nolimit => 1})->rows || new Mojo::Collection([])
        } ref $$opts{add_vocs} ? @{ $$opts{add_vocs} } : $m->vocs->each
    }) if $$opts{add_vocs};
    
    $return;
}

sub update {
    my $m = shift;
    my $data = $m->_opts(@_);
    $data = { map {$_ => $m->c->data->{$_}} grep {exists $m->c->data->{$_}} $m->columns->each } if !keys %$data;
    $$data{fake} ||= 0;

    if (my $id = $data->{id} || $m->c->id) {
        delete $$data{id};
        $m->db->update($m->entity, $data, {id => $id});
    }

    $m;
}

sub create {
    my $m = shift;
    my $data = $m->_opts(@_);
    $data = { map {$_ => $m->c->data->{$_}} grep {exists $m->c->data->{$_}} $m->columns->each } if !keys %$data;
    $$data{fake} = $m->c->sid if !exists $$data{fake};
    delete $$data{id};

    my $id = $m->db->insert($m->entity, $data, {returning => 'id'})->hash->{id};
    $m->c->id($id) if $m->entity eq $m->c->entity;
    
    $id;
}

sub delete {
    my $m = shift;
    my ($id, $opts) = $m->_id_opts(@_);
    $id = $m->c->id if !$id && $m->c->entity eq $m->entity;
    return undef if !$id;
    $$opts{hard} ? $m->db->delete($m->entity, {id => $id}) : $m->db->update($m->entity, {fake => $$opts{fake}||-1}, {id => $id});
}

sub _order_by {
    my ($m, $fields) = @_;
    my @order;
    my $table = $m->entity;
    if (ref $fields eq 'HASH') {
        for my $f (keys %$fields) {
            next if $f !~ /\./ && (!$m->field($f) || !$m->field($f)->{sortable});
            next if $$fields{$f} !~ /^asc|desc$/i;
            $f = "$table.$f" if $f !~ /\./;
            push @order, $f . ' ' . uc($$fields{$f});
        }
    }
    elsif (ref $fields eq 'ARRAY') {
        for my $f (@$fields) {
            if (ref $f eq 'HASH') {
                push @order, map {
                    ($_ =~ /\./ ? $_ : "$table.$_") . ' ' . uc($$f{$_})
                } grep {
                    $$f{$_} =~ /^asc|desc$/i && (/\./ || ($m->field($_) && $m->field($_)->{sortable}))
                } keys %$f;
            }
            elsif (!ref $f) {
                next if $f !~ /\./ && (!$m->field($f) || !$m->field($f)->{sortable});
                $f = "$table.$f" if $f !~ /\./;
                push @order, $f;
            }
        }
    }
    elsif (!ref $fields) {
        push @order, ($fields =~ /\./ ? $fields : "$table.$fields") if $fields =~ /\./ || ($m->field($fields) && $m->field($fields)->{sortable});
    }
    ~~@order ? 'ORDER BY ' . join(', ', @order) : '';
}

=pod

=head1 Beaver::Model::Pg

=encoding utf8

=head1 SYNOPSIS

    package MyApp::Model::Goods;
    use Mojo::Base 'Beaver::Model::Pg';

    $m->item->row;
    $m->list->rows;

=head1 DESCRIPTION

L<Beaver::Model::Pg> is base class for Beaver low-level models based on Pg database.

=head1 ATTRIBUTES

=head2 backend

Reference to backend config section in config

=head2 pg

Mojo::Pg instance

=head2 db

Mojo::Pg db instance

=head2 sql

Mojo::Pg abstract instance

=over 1

=item item

Get entity by id

    # WHERE id = 1000
    $m->item(1000);

Get item with id from controller instance (usually taken from request URL)

    $m->item;

=item list

Get list of entities

    # LIMIT <portion>, OFFSET <start>
    $m->list({
        potion  => 10,
        start   => 0,
    })

Select all records without LIMIT and OFFSET
    
    $m->list({
        nolimit => 1,
    });

Sort result set

    # ORDER BY id ASC
    $m->list({
        sort   => 'id',
    });

    # ORDER BY label ASC, id ASC
    $m->list({
        sort   => [qw(label id)],
    });

Change sort order

    # ORDER BY id DESC
    $m->list({
        sort => { id => 'desc' },
    });

It's possible to set more then 1 key but it's bad practice - sort result will be unpredictable

    # ORDER BY label DESC, id ASC
    # or maybe
    # ORDER BY id ASC, label DESC
    $m->list({
        sort => {
            label   => 'desc',
            id      => 'asc',
        },
    });

Use array ref instead

    # ORDER BY label DESC, id ASC
    $m->list({
        sort => [
            { label => 'desc' },
            { id    => 'asc'  },
        ]
    });

Add evalueted fields in result:

    $m->list({
        add_fields  => {
            sum_field1_field2  => sub {
                my $row = shift;
                $row->{field1}+$row{field2};
            },
        },
    });

If model fields described as vocabularies you can add corresponding vocabularies to result

    $m->list({
        add_vocs    => 1,
    });

Or only several vocabularies

    $m->list({
        add_vocs    => [qw(id_type id_kind)],
    });

Also you can join vocabularies directly to result items

    $m->list({
        join_vocs  => {
            id_type => type_label,
        },
    })->rows->first->{type_label};

Eval total count of rows in the result

    $m->list({
        count   => 1,
    });

Specify table fields which will be included in result set

    $m->list({
        fields  => [qw(id label fake)],
    });

By default list returns all fields

    $m->list({
        fields  => '*',
    });

Note that B<join_vocs> will add corresponding fields independently.

=item delete

Delete record by ID

    $m->delete(100);

Delete row by current entity ID
    
    $m->delete;

B<Beaver::Model::Pg> uses "soft" deletion which doesn't remove row from table but marks it as deleted by setting field fake to negative value (-1). If you need to remove record phisically use option B<hard>.

    $m->delete(100, {hard => 1});

You can set another value of fake. If option B<fake> is skipped value -1 is used for fake.

    $m->delete(100, {fake => -2});

=back

=cut

1;
