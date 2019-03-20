package Beaver::Model::SQLite;

use Mojo::Base 'Beaver::Model';
use Data::Dumper;

has [qw(sql)];

# single connection
my $sql;

sub init {
    my $m = shift;
    $m->sql($sql ||= $m->app->connect($m->backend));
    $m;
}

sub item {
    my ($m, $id) = @_;
    $id ||= 0;
    $id = $m->instance->id if !$id && $m->instance->entity eq $m->entity;
    return undef if !$id;
    $m->sql->db->query(qq{
        SELECT * FROM @{[ $m->entity ]} WHERE id = ?
    }, $id)->hash;
}

sub list {
    my ($m, $list) = @_;
    $list ||= {};
    $list->{portion} ||= 10;
    $list->{start} ||= 0;
    $m->sql->db->query(qq{
        SELECT * FROM @{[ $m->entity ]} LIMIT ? OFFSET ?
    }, $list->{portion}, $list->{start})->hashes;
}

sub create {
    my ($m, $data) = (shift, _hash(@_));
    $$data{fake} //= \q{ABS(RANDOM())};
    # model check fiedls must be added
    $m->sql->db->insert($m->entity, $data)->last_insert_id;
}

sub update {
    my ($m, $data) = (shift, _hash(@_));
    warn Dumper($data);
    $$data{fake} ||= 0;
    $$data{id} ||= 0;
    $$data{id} = $m->instance->id if !$$data{id} && $m->instance->entity eq $m->entity;
    return undef if !$$data{id};
    # model check fields must be updated
    $m->sql->db->update($m->entity, { map { $_ => $$data{$_} } grep {$_ ne 'id'} keys %$data }, {id => $$data{id}});
}

sub _hash { ref $_[0] eq 'HASH' ? $_[0] : @_%2 == 0 ? { @_ } : { @_, undef } }

1;
