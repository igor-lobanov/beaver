package Beaver::Bootstrap3::Widget::Jumbotron;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'jumbotron',
        $self->oid,
    );
    $self;
}

1;

__DATA__

@@ widgets/jumbotron.html.ep
% if ($wg->props->{fullwidth}) {
<div <%= $wg->pack_attrs %>><div class="container"><%= $wg->content %></div></div>
% }
% else {
<div <%= $wg->pack_attrs %>><%= $wg->content %></div>
% }
