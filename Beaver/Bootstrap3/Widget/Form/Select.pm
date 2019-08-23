package Beaver::Bootstrap3::Widget::Form::Select;
use Mojo::Base 'Beaver::Bootstrap3::WidgetFormElement';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'form-control',
        $self->oid,
    );
    $self;
}

1;

__DATA__

@@ widgets/form-select.html.ep
<div class="<%= $wg->field_class %>">
<label class="control-label" for="<%= $wg->oid %>"><%= $wg->props->{label} %></label>
%   if ($wg->props->{readonly}) {
<div><%= join('; ', map {$_->{label}} grep { $wg->attrs->{value} == $_->{id} } @{ $wg->props->{values} } ) %></div>
%   }
%   else {
<select <%= $wg->pack_attrs({class => $wg->attrs->{class}}) %>
<%= $wg->attrs->{'data-form'} ? $wg->pack_attrs({'data-form' => $wg->attrs->{'data-form'}}) : '' %>
name="<%= $wg->attrs->{name} %>">
%       if ($wg->props->{placeholder}) {
<option value=""></option>
%       }
%       for my $option ($wg->props->{values}->each) {
<option <%= $option->{id} == $wg->attrs->{value} ? 'selected' : '' %> value="<%= $option->{id} %>"><%= $option->{label} %></option>
%       }
</select>
%   }
</div>
% js_onload begin
$(".<%= $wg->oid %>").select2(<%= json {theme => 'bootstrap', (placeholder => $wg->props->{placeholder}, allowClear => \1) x!! exists $wg->props->{placeholder}} %>);
% end

