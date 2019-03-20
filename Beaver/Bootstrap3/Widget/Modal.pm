package Beaver::Bootstrap3::Widget::Modal;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'modal',
        'modal-lg'
        $self->oid,
    );
    $self->attrs->{tabindex} ||= -1;
    $self;
}

1;

__DATA__

@@ widgets/modal.html.ep
<div <%= $wg->pack_attrs %> role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
% if ($wg->props->{title}) {
        <h4 class="modal-title"><%= $wg->props->{title} %></h4>
% }
      </div>
      <div class="modal-body"><%= $wg->content %></div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
