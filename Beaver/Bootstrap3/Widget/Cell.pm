package Beaver::Bootstrap3::Widget::Cell;
use Mojo::Base 'Beaver::Bootstrap3::Widget';
# -col => {lg => 1, md => 2, sm => 3, xs => 4}, -offset => {lg => 2}
sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        $self->oid,
    );
    if ($self->props->{col}) {
        map {
            push @{ $self->attrs->{class} }, join('-', 'col', $_, $self->props->{col}{$_})
        } keys %{ $self->props->{col} };
    }
    if ($self->props->{offset}) {
        map {
            push @{ $self->attrs->{class} }, join('-', 'col', $_, 'offset', $self->props->{offset}{$_})
        } keys %{ $self->props->{offset} };
    }
    $self;
}

1;

__DATA__

@@ widgets/cell.html.ep
<div <%= $wg->pack_attrs %>><%= $wg->content %></div>
