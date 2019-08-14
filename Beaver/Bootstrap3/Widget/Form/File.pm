package Beaver::Bootstrap3::Widget::Form::File;
use Mojo::Base 'Beaver::Bootstrap3::WidgetFormElement';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self;
}

1;

__DATA__

@@ widgets/form-file.html.ep
<div class="<%= $wg->field_class %>">
<label for="<%= $wg->oid %>"><%= $wg->props->{label} %></label>
% if ($wg->props->{readonly}) {
<div><%= $wg->props->{label} %> value</div>
% }
% else {
<input type="file" class="form-control" <%= $wg->props->{multiple} ? 'multiple' : '' %> multiple name="<%= $wg->attrs->{name} %>" value="" id="<%= $wg->oid %>" data-form="<%= $wg->props->{form} %>">
% }
</div>
