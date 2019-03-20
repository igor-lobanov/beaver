package Beaver::Bootstrap3::Widget::Alert;
use Mojo::Base 'Beaver::Bootstrap3::Widget';
use Mojo::Collection;

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'alert',
        ('alert-' . $self->props->{context}) x!! ($self->props->{context}),
        ('alert-dismissible') x!! ($self->props->{dismissible}),
        $self->oid,
    );
}

1;

=encoding utf8

=head1 NAME

Beaver::Bootstrap3::Widget::Alert - alert widget

=head1 SYNOPSIS

  <%= widget alert => {
    -context        => 'success',
    -dismissible    => 1,
    -autohide       => 3000,
    class           => 'in fade'
  } => begin %>Alert!!!<% end %>

=head1 DESCRIPTION

L<Beaver::Bootstrap3::Widget::Alert> provides Bootstrap3 alert componnent widget backend for L<MojoX::Plugin::Widgets>.

=head1 PROPERTIES

L<Beaver::Bootstrap3::Widget::Alert> implements following properties.

=head2 context

  <%= widget alert => {
    -context => 'success',
  } => begin %>Alert<% end %>

Applies one of Bootstrap3 contexts (primary, success, info, warning, danger) to alert.

=head2 dismissible

  <%= widget alert => {
    -dismissible => 1,
  } => begin %>Alert<% end %>

Close button will be added to component.

=head2 autohide

  <%= widget alert => {
    -autohide => 3000,
  } => begin %>Alert<% end %>

Alert will be automatically closed after specified in property amount of milliseconds.

=head1 SEE ALSO

L<Mojolicious>, L<Beaver::Plugin::Widgets>.

=cut

__DATA__

@@ widgets/alert.html.ep
<div role="alert" <%= $wg->pack_attrs %>><%==
  $wg->props->{dismissible}
    ? qq{<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>}
    : ''
%><%= $wg->content %></div>
% if ($wg->props->{autohide}) {
% js_onload begin
window.setTimeout(function() { $(".alert.<%= $wg->oid %>").fadeTo(500, 0).slideUp(500, function(){ $(this).remove(); }); }, <%= $wg->props->{autohide} %>);
% end
% }
