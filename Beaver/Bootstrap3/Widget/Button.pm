package Beaver::Bootstrap3::Widget::Button;
use Mojo::Base 'Beaver::Bootstrap3::Widget';
use Mojo::Collection;

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self->props->{tag} ||= 'button';
    $self->attrs->{disabled} = 'disabled' if $self->props->{disabled} && $self->props->{tag} ne 'a';
    push @{$self->attrs->{class} ||= []}, (
        'btn',
        ($self->props->{context} ? 'btn-' . $self->props->{context} : ()),
        ($self->props->{size} ? 'btn-' . $self->props->{size} : ()),
        ($self->props->{block} ? 'btn-block' : ()),
        ($self->props->{active} ? 'active' : ()),
        ($self->props->{disabled} && $self->props->{tag} eq 'a' ? 'disabled' : ()),
        $self->oid,
    );
    $self;
}

1;

=encoding utf8

=head1 NAME

Beaver::Bootstrap3::Widget::Button - button widget

=head1 SYNOPSIS

  <%= widget button => {
    -tag            => 'a',
    -context        => 'success',
    -size           => 'lg',
    -block          => 1,
    -disabled       => 1,
    -active         => 1,
  } => begin %>Save<% end %>

=head1 DESCRIPTION

L<Beaver::Bootstrap3::Widget::Button> provides Bootstrap3 button componnent widget backend for L<MojoX::Plugin::Widgets>.

=head1 PROPERTIES

L<Beaver::Bootstrap3::Widget::Button> implements following properties.

=head2 context

  <%= widget button => {
    -context => 'success',
  } => begin %>Save<% end %>

Applies one of Bootstrap3 contexts (primary, success, info, warning, danger) to button.
Additionally context 'link' is available which makes button look like link and behave
like button.

=head2 size

  <%= widget button => {
    -size => 'lg',
  } => begin %>Save<% end %>

Applies one of Bootstrap3 sizes (lg, md, sm, xs) to button.

=head2 block

  <%= widget button => {
    -block => 1,
  } => begin %>Save<% end %>

Makes button fullwidth.

=head2 disabled

  <%= widget button => {
    -disabled => 1,
  } => begin %>Save<% end %>

Makes button disabled.

=head2 active

  <%= widget button => {
    -active => 1,
  } => begin %>Save<% end %>

Makes button active.

=head2 tag

  <%= widget button => {
    -tag => 'a',
  } => begin %>Save<% end %>

Selects html tag which will be used for button (<a>, <input> or <button>). By default <button> is used.

=head1 SEE ALSO

L<Mojolicious>, L<Beaver::Plugin::Widgets>.

=cut

__DATA__

@@ widgets/button.html.ep
<<%= $wg->props->{tag} %> role="button" <%= $wg->pack_attrs %>><%= $wg->content %></<%= $wg->props->{tag} %>>
% if ($wg->props->{disabled} && $wg->props->{tag} eq 'a') {
% js_onload begin
$('.<%= $wg->oid %>').on('click',function(){return false;});
% end
% }
