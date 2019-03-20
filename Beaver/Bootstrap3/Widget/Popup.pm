package Beaver::Bootstrap3::Widget::Popup;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'modal',
        'modal-popup',
        $self->oid,
    );
    $self->attrs->{tabindex} ||= -1;
    $self;
}

1;

__DATA__

@@ widgets/popup.html.ep
<div <%= $wg->pack_attrs %>>
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <iframe frameborder="0" src="about:blank"></iframe>
            </div>
        </div>
    </div>
</div>
% js_onload begin
$(".<%= $wg->oid %>").on('shown.bs.modal', function(event) {
    $(this).find('.modal-body').outerHeight(
        $(this).find('.modal-content').outerHeight()-$(this).find('.modal-header').outerHeight()-4
    );
    $(this).find('iframe').attr('src', $(event.relatedTarget).data('href') || 'about:blank');
}).on('hidden.bs.modal', function(event) {
    $(this).find('iframe').attr('src', 'about:blank');
});
% end
