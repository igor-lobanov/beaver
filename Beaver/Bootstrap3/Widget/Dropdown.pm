package Beaver::Bootstrap3::Widget::Dropdown;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'dropdown',
        ($self->props->{open} ? 'open' : ()),
        $self->oid,
    );
    $self;
}

1;

=encoding utf8

=head1 NAME

Beaver::Bootstrap3::Widget::Dropdown - dropdown widget

=head1 SYNOPSIS

    <%= widget dropdown => {
        -context    => 'success',
        -size       => 'lg',
        -block      => 1,
        -items      => [
            'Menu block heading',
            {
                label       => 'Item 1',
                href        => '#item1',
            },
            {
                label       => 'Disabled item',
                href        => '#disabled',
                disabled    => 1,
            },
            '-', # separator
            {
                text        => 'Other item',
                href        => '#other',
            },
        ],
    } => begin %>Dropdown menu<% end %>

=head1 DESCRIPTION

L<Beaver::Bootstrap3::Widget::Dropdown> provides Bootstrap3 dropdown componnent widget backend for L<MojoX::Plugin::Widgets>.

=head1 PROPERTIES

L<Beaver::Bootstrap3::Widget::Dropdown> implements following properties.

=head2 context

  <%= widget dropdown => {
    -context => 'success',
  } => begin %>Dropdown<% end %>

Applies one of Bootstrap3 contexts (primary, success, info, warning, danger) to dropdown.

=head2 size

  <%= widget dropdown => {
    -size => 'lg',
  } => begin %>Dropdown<% end %>

Sets size of dropdown button.

=head2 block

  <%= widget dropdown => {
    -block => 1,
  } => begin %>Dropdown<% end %>

Dropdown with block property set occupies all width of parent container.

=head2 open

  <%= widget dropdown => {
    -open => 1,
  } => begin %>Dropdown<% end %>

Dropdown will be loaded in open state.

=head2 items

  <%= widget dropdown => {
    -items => [
        'Block of items',
        {
            label       => 'Item 1',
            href        => '#item1',
        },
        {
            label       => 'Item 2 (disabled)',
            href        => '#item2',
            disabled    => 1,
        },
        '-',
        'Another block of items',
        {
            label       => 'Item 3',
            href        => '#item3',
        },
    ],
  } => begin %>Dropdown<% end %>

Array ref with dropdown menu content. If array element is hash ref then item will be link with target from href element.
Displayed text of link are provided by 'label' element.
Links can be disabled if hash contains element 'disabled'.
If element is '-' then divider will be placed in this point, if any other scalar - heading text.

=head1 SEE ALSO

L<Mojolicious>, L<Beaver::Plugin::Widgets>.

=cut

__DATA__

@@ widgets/dropdown.html.ep
<div <%= $wg->pack_attrs %>>
<%= widget button => {
    -context        => $wg->props->{context} || 'default',
    class           => 'dropdown-toggle',
    id              => $wg->oid.'-btn',
    'data-toggle'   => 'dropdown',
    'aria-haspopup' => 'true',
    'aria-expanded' => 'true',
    (map {'-'.$_ => $wg->props->{$_}} grep {defined $wg->props->{$_}} qw(size block)),
} => begin %><%= $wg->content %> <span class="caret"></span><% end %>
  <ul class="dropdown-menu" aria-labelledby="<%= $wg->oid %>-btn">
%   for my $item (@{ $wg->props->{items} }) {
%       if (ref $item) {
    <li<%== $item->{disabled} ? ' class="disabled"' : '' %>><a href="<%= $item->{disabled} ? '#' : $item->{href} %>"><%= $item->{label} %></a></li>
%       }
%       elsif ($item eq '-') {
    <li role="separator" class="divider"></li>
%       }
%       else {
    <li class="dropdown-header"><%= $item %></li>
%       }
%   }
  </ul>
</div>
