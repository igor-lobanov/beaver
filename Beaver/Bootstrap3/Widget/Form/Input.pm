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
<label for="<%= $wg->oid %>"><%= $wg->props->{label} %></label>
<input type="text" class="form-control" name="<%= $wg->props->{name} %>" value="" id="<%= $wg->oid %>" data-form="<%= $wg->props->{form} %>">
</div>
