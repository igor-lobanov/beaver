package Beaver::Bootstrap3::Widget::Container;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        $self->props->{fluid} ? 'container-fluid' : 'container',
        $self->oid,
    );
    $self;
}

1;

__DATA__

@@ widgets/container.html.ep
<div <%= $wg->pack_attrs %>><%= $wg->content %></div>
