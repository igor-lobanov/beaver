package Beaver::Bootstrap3::Widget::Breadcrumbs;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'breadcrumb',
        $self->oid,
    );
    $self->props->{items}[-1]{active} = 1 if ~~@{ $self->props->{items} || [] };
    $self;
}

1;

=encoding utf8

=head1 NAME

Beaver::Bootstrap3::Widget::Breadcrumbs - breadcrumbs widget

=head1 SYNOPSIS

    <%= widget breadcrumbs => {
        -items => [
            {
                href    => '#root',
                label   => 'Root',
                icon    => [fas => 'home'],
            },
            {
                href    => '#item',
                label   => 'Item',
            },
            {
                href    => '#subitem',
                label   => 'Subitem',
            },
        ],
    } %>

=head1 DESCRIPTION

L<Beaver::Bootstrap3::Widget::Breadcrumbs> provides Bootstrap3 breadcrumbs componnent widget backend for L<MojoX::Plugin::Widgets>.

=head1 PROPERTIES

L<Beaver::Bootstrap3::Widget::Breadcrumbs> implements following properties.

=head2 items

    <%= widget breadcrumbs => {
        -items => [
            {
                href    => '#root',
                label   => 'Root',
                fa      => 'fa-home',
            },
            {
                href    => '#item',
                label   => 'Item',
            },
            {
                href    => '#subitem',
                label   => 'Subitem',
            },
        ],
    } %>

Array ref with breadcrumbs elements. Each element is a hash with elements 'href' and 'label'.
Last element of array is dispalyed as text always.

=head1 SEE ALSO

L<Mojolicious>, L<Beaver::Plugin::Widgets>.

=cut

__DATA__

@@ widgets/breadcrumbs.html.ep
<ol <%= $wg->pack_attrs %>>
%   for my $item (@{ $wg->props->{items} }) {
%       if ($item->{active}) {
    <li class="active"><%= $item->{label} %></li>
%       }
%       else {
    <li><a href="<%= $item->{href} %>"><%== $$item{icon} ? $wg->icon($$item{icon}).' ' : '' %><%= $item->{label} %></a></li>
%       }
%   }
</ol>
