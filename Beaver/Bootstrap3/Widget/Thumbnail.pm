package Beaver::Bootstrap3::Widget::Thumbnail;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'thumbnail',
        $self->oid,
    );
    $self;
}

1;

__DATA__

@@ widgets/thumbnail.html.ep
<div <%= $wg->pack_attrs %>><img <%= $wg->pack_attrs($wg->props->{image}) %>><div class="caption"><%= $wg->content %></div></div>
