package Beaver::Bootstrap3::Widget::NavBar;
use Mojo::Base 'Beaver::Bootstrap3::Widget';
use Mojo::ByteStream 'b';
use Mojo::Util qw(xml_escape);

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self->props->{style} ||= 'default';
    push @{$self->attrs->{class} ||= []}, (
        'navbar',
        'navbar-'.$self->props->{style},
        ($self->props->{inverse} ? 'navbar-inverse' : ()),
        ($self->props->{fixed} ? 'navbar-fixed-'.$self->props->{fixed} : ()),
        $self->oid,
    );
    $self;
}

sub item {
    my ($self, $item) = @_;
    if ($item->{type} eq 'button') {
        $self->app->widget('button' => {
            class => 'navbar' . ($item->{class} ? " $item->{class}" : ''),
        } => sub {
           ($item->{icon} ? $self->icon($item->{icon}) : '') . ($item->{label} || '');
        });
    }
    else {
        qq{<li@{[ $item->{active} ? ' class="active"' : '' ]}><a href="@{[ xml_escape($item->{href}) ]}">@{[ xml_escape($item->{label}) ]}</a></li>};
    }
}

1;

__DATA__

@@ widgets/nav_bar.html.ep
<nav <%= $wg->pack_attrs %>>
    <div class="container-fluid">
        <div class="navbar-header">
%   for my $item (grep {$_->{section} eq 'brand'} @{ $wg->props->{items} }) {
            <a class="navbar-brand" href="<%= $$item{href} %>"><%= $$item{icon} ? $wg->icon($$item{icon}) : '' %><%= $$item{label} %></a>
%   }
        </div>
        <ul class="nav navbar-nav navbar-collapse">
%   for my $item (grep {$_->{section} eq 'left' || !$_->{section}} @{ $wg->props->{items} }) {
%       if ($$item{type} eq 'button') {
            <%= widget button => {class => "navbar-btn $$item{class}"} => begin %><%= $$item{icon} ? $wg->icon($$item{icon}) : '' %><%= $$item{label} %><% end %>
%       }
%       else {
            <li<%== $item->{active} ? ' class="active"' : '' %>><a href="<%= $item->{href} %>"><%= $item->{label} %></a></li>
%       }
%   }
        </ul>
        <ul class="nav navbar-nav navbar-right">
%   for my $item (grep {$_->{section} eq 'right'} @{ $wg->props->{items} }) {
            <li<%== $item->{active} ? ' class="active"' : '' %>><a href="<%= $item->{href} %>"><%== $$item{icon} ? $wg->icon($$item{icon}) : '' %><%= $item->{label} %></a></li>
%   }
        </ul>
    </div>
</nav>
