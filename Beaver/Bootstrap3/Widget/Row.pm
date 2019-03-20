package Beaver::Bootstrap3::Widget::Row;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'row',
        $self->oid,
    );
    $self;
}

1;

__DATA__

@@ widgets/row.html.ep
<div <%= $wg->pack_attrs %>><%= $wg->content %></div>
