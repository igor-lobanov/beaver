package Beaver::Bootstrap3::WidgetFormElement;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub field_class {
    my $self = shift;
    my @class = ('form-group');
    if ($self->props->{col}) {
        map {
            push @class, join('-', 'col', $_, $self->props->{col}{$_})
        } keys %{ $self->props->{col} };
    }
    return join(' ', @class);
}

1;

