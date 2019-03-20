package Beaver::Model;
use Mojo::Base -base;
use Data::Dumper;

has [qw(backend app entity instance schema)];

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self->init(@_);
}

sub init { $_[0] }

sub item {
    my ($m, $id) = @_;
    {
        entity => $m->entity,
        id => $id || $m->instance->id || 0,
    };
}

sub list {
    wantarray ? [] : ([], 0)
}

1;
