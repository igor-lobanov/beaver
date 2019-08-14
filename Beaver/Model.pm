package Beaver::Model;
use Mojo::Base -base;
use Mojo::Collection;

has [qw(backend app entity definition c)];

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self->init(@_);
}

sub init { $_[0] }

sub item {
    my ($m, $id) = @_;
    {
        entity  => $m->entity,
        id      => $id || $m->c->id || 0,
    };
}

sub list {
    wantarray ? [] : ([], 0)
}

sub fields {
    my ($m, $name) = @_;
    my $map = { map {$_->{name} => $_} @{ $m->definition } };
    return $name ? $$map{$name} : $m->definition || [];
}

sub field {
    $_[0]->fields($_[1]);
}

sub columns {
    my ($m) = @_;
    return new Mojo::Collection(map { $_->{name} } @{ $m->definition });
}

sub vocs {
    my ($m) = @_;
    my %vocs = map { $m->fields($_)->{vocabulary} => 1 } grep { $m->fields($_)->{vocabulary} } @{ $m->columns };
    return new Mojo::Collection(keys %vocs);
}

1;
