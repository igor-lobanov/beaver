package Beaver::Bootstrap3::Widget::Form::Input;
use Mojo::Base 'Beaver::Bootstrap3::WidgetFormElement';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self;
}

1;

__DATA__

@@ widgets/form-input.html.ep
<div class="<%= $wg->field_class %>">
<label class="control-label" for="<%= $wg->oid %>"><%= $wg->props->{label} %></label>
%   if ($wg->props->{readonly}) {
<div><%= $wg->attrs->{value} %></div>
%   }
%   else {
<input id="<%= $wg->oid %>" type="text" class="form-control"
<%= $wg->attrs->{'data-form'} ? $wg->pack_attrs({'data-form' => $wg->attrs->{'data-form'}}) : '' %>
name="<%= $wg->attrs->{name} %>" value="<%= $wg->attrs->{value} %>">
%   }
</div>
