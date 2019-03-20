package Beaver::Bootstrap3::Widget::Tab;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'tab-pane',
        ($self->props->{active} ? ('active', 'in') : ()),
        $self->oid,
    );
    $self;
}

1;

__DATA__

@@ widgets/tab.html.ep
<div <%= $wg->pack_attrs %>><%= $wg->content %></div>
