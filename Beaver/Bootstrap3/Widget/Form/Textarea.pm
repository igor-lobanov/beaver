package Beaver::Bootstrap3::Widget::Form::Textarea;
use Mojo::Base 'Beaver::Bootstrap3::WidgetFormElement';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self;
}

1;

__DATA__

@@ widgets/form-textarea.html.ep
<div class="<%= $wg->field_class %>">
<label class="control-label" for="<%= $wg->oid %>"><%= $wg->props->{label} %></label>
%   if ($wg->props->{readonly}) {
<div>
%       if ($wg->attrs->{value} ) {
<pre><%= $wg->attrs->{value} || $wg->content %></pre>
%       }
</div>
%   }
%   else {
<textarea id="<%= $wg->oid %>" class="form-control" <%== $wg->attrs->{rows} ? 'rows="' . $wg->attrs->{rows} . '"' : '' %>
<%= $wg->attrs->{'data-form'} ? $wg->pack_attrs({'data-form' => $wg->attrs->{'data-form'}}) : '' %>
name="<%= $wg->attrs->{name} %>"><%= $wg->attrs->{value} || $wg->content %></textarea>
%   }
</div>
