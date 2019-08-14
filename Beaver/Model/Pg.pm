package Beaver::Model::Pg;

use Mojo::Base 'Beaver::Model';
has [qw(backend version pg db sql)];
use Data::Dumper;

my $pg;

sub init {
    my $m = shift;
    $m->pg($pg ||= $m->app->connect($m->backend));
    $m->db($pg->db);
    $m->sql($pg->abstract);
    my $mg = $m->pg->migrations->name(ref $m)->from_data(ref $m);
#    state $version = 0;
#    $mg->migrate, $version = $mg->latest if $version < $mg->latest;
    $mg->migrate;
    $m;
}

# item returns approved record (fake=0) or new record of current user (fake=<sid>)
sub item {
    my ($m, @args) = @_;
    my ($id, $opts) = (0, {});
    for (@args) {
        $id = $_, next if !ref $_;
        $opts = $_, next if ref $_;
    }
    $id = $m->c->id if !$id && $m->c->entity eq $m->entity;
    return undef if !$id;
    my $item = $m->db->query(qq{
        SELECT *
        FROM @{[ $m->entity ]}
        WHERE id = ? AND (fake = 0 OR fake = ?)
    }, $id, $m->c->sid)->hash;
    if ($$opts{add_vocs}) {
        for my $voc ($m->vocs->each) {
            $item->{vocs}{$voc} = $m->c->model($m->c->load_model($voc))->list->{data}{rows};
        }
    }
    return $item;
}

# $m->list({
#    nolimit => 1, # 0|1
#    start   => 100,
#    portion => 100,
#    order   => 'field1',
#    order   => [qw(field1 field2)]
#    order   => [{field1 => 'asc', field2 => 'desc')],
#    order   => {field1 => 'asc'},
#    order   => {field1 => 'asc', field2 => 'desc'}, # bad practice
#    add_vocs    => 1,
#    add_vocs    => [qw(voc1 voc2)],
#    count   => 1,
#    add_fields  => {
#       sum_field1_field2  => sub {
#           my $row = shift;
#           $row->{field1}+$row{field2};
#       }
#    },
#    join_vocs  => {
#       id_voc1 => voc1_label,
#    },
#    where   => {
#        field1  => 'val1',
#        field2  => 'val1',
#    },
#    fields  => '*',
#    fields  => [qw(field1 field2)],
# })
# {
#   rows    => [{...}],
#   count   => 101,     # if $opts->{count}
#   count   => 0,       # if !$opts->{count}
#   vocs    => {voc1 => [{ id=>1, label=>'value 1' },...], ...} # if $opts->{add_vocs}
# }
sub list {
    my ($m, $opts) = @_;
    $opts ||= {};

    my $table = $m->entity;
    my $order = $$opts{order} ? $m->_order_by($opts->{order}) : '';
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

    my $result = {};
    $$result{rows} = $m->db->query(qq{
        SELECT $fields
        FROM $table $joins
        WHERE $table.fake = 0
        $order
        $limit
    })->hashes;
    $$result{rows} = $$result{rows}->each(sub {my ($e) = @_; $e->{$_} = $$opts{add_fields}{$_}->($e) for keys %{$$opts{add_fields}}}) if $$opts{add_fields};

    $$result{count} = $$opts{count} ? $m->db->query(qq{ SELECT COUNT(*) AS count FROM $table WHERE fake = 0 })->hash->{count} : 0;

    if ($$opts{add_vocs}) {
        $$result{vocs}{$_} = $m->c->load_model($_)->list({order => 'label', nolimit => 1})->{rows} || [] for ref $$opts{add_vocs} ? @{ $$opts{add_vocs} } : $m->vocs->each;
    }
    
    $result;
}

sub update {
    my ($m, $data) = @_;
    $data ||= { map {$_ => $m->c->data->{$_}} grep {exists $m->c->data->{$_}} $m->columns->each };
    $$data{fake} ||= 0;
    if (my $id = $data->{id} || $m->c->id) {
        delete $$data{id};
        $m->db->update($m->entity, $data, {id => $id});
    }
}

sub create {
    my ($m, $data) = @_;
    $data ||= { map {$_ => $m->c->data->{$_}} grep {exists $m->c->data->{$_}} $m->columns->each };
    $$data{fake} = $m->c->sid if !exists $$data{fake};
    delete $$data{id};
    $m->c->id($m->db->insert($m->entity, $data, {returning => 'id'})->hash->{id});
    $m->c->id;
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

=over 1

=item item

Get entity by id

    # WHERE id = 1000
    $m->item(1000);

Get item with id from controller instance (usually taken from request URL)

    $m->item();

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

    # ORDER BY id ASC
    $m->list({
        order   => 'id',
    });

    # ORDER BY id DESC
    $m->list({
        order => { id => 'desc' },
    });

It's possible to set more then 1 key but it's bad practice - sort result will be unpredictable - use array ref instead

    # ORDER BY label DESC, id ASC
    $m->list({
        order => [
            { label => 'desc' },
            { id    => 'asc'  },
        ]
    });

Add evalueted fields in result:

    # {
    #   a   => 1,
    #   b   => 2,
    #   sum => 3,
    # }
    $m->list({}, {
        sum => sub {
            my ($r) = @_;
            $r->{a}+$r->{b};
        },
    });

=back

=cut

1;
