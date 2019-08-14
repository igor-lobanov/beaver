package Beaver::Bootstrap3::Widget::SideBar;
use Mojo::Base 'Beaver::Bootstrap3::Widget';
use Mojo::ByteStream 'b';
use Mojo::Util qw(xml_escape);

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'beaver-sidebar',
        $self->oid,
    );
    $self;
}

1;

__DATA__

@@ widgets/side_bar.html.ep
<nav <%= $wg->pack_attrs %>>
    <button class="btn beaver-sidebar-dismiss">
        <i class="fas fa-arrow-left"></i>
    </button>
%   if ($wg->props->{header}) {
    <div class="beaver-sidebar-header">
        <h3><%= $wg->props->{header} %></h3>
    </div>
%   }
%   if (~~@{ $wg->props->{items} }) {
%       my $count = 1;
    <ul class="list-unstyled beaver-sidebar-content">
%       for my $item (@{ $wg->props->{items} }) {
%           if (ref $item && $item->{items}) {
        <li>
            <a href="#<%= $wg->oid %>-submenu-<%= $count %>" data-toggle="collapse" role="button" aria-expanded="false"><%= $item->{label} %></a>
            <ul class="collapse list-unstyled" id="<%= $wg->oid %>-submenu-<%= $count %>">
%               for my $subitem (@{ $item->{items} || [] }) {
                <li><a href="<%= $subitem->{href} %>"><%= $subitem->{label} %></a></li>
%               }
            </ul>
        </li>
%               $count++;
%           }
%           elsif (ref $item) {
        <li><a href="<%= $item->{href} %>"><%= $item->{label} %></a></li>
%           }
%           else {
        <p><%= $item %></p>
%           }
%       }
    </ul>
%   }
</nav>
