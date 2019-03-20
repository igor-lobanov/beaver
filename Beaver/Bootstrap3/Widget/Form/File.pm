package Beaver::Bootstrap3::Widget::Form::File;
use Mojo::Base 'Beaver::Bootstrap3::WidgetFormElement';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self->props->{button_label} ||= 'Загрузить';
    $self->attrs->{multiple} = 'multiple' if $self->props->{multiple};
    $self->attrs->{type} = 'file';
    $self;
}

1;

__DATA__

@@ widgets/form-file.html.ep
<div class="<%= $wg->field_class %>">
    <div><label for="<%= $wg->oid %>"><%= $wg->props->{label} %></label></div>
    <div class="btn-group">
        <label class="btn btn-primary" for="<%= $wg->oid %>"><%= $wg->props->{button_label} %></label>
        <button class="btn btn-primary" data-toggle="collapse" data-target=".<%= $wg->oid %>-status"><span class="fas fa-caret-down"></span></button>
    </div>
    <input <%= $wg->pack_attrs %>
        data-form="<%= $wg->props->{form} %>"
        data-status=".<%= $wg->oid %>-status"
        data-upload-url="<%= $wg->props->{upload_url} || '#' %>"
        data-remove-url="<%= $wg->props->{remove_url} || '#' %>"
        class="hidden form-control cs-file-upload" id="<%= $wg->oid %>" name="<%= $wg->props->{name} %>">
%= widget well => {-oid => $wg->oid . '-status', class => 'collapse fade well-popup'} => begin
    <div class="cs-file-status"></div>
    <div class="progress"><div class="progress-bar progress-bar-success"></div></div>
% end
</div>
