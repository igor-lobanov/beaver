package Beaver::Bootstrap3::Widget::Well;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'well',
        ($self->props->{size} ? 'well-'.$self->props->{size} : ()),
        $self->oid,
    );
    $self;
}

1;

__DATA__

@@ widgets/well.html.ep
<div <%= $wg->pack_attrs %>><%= $wg->content %></div>
