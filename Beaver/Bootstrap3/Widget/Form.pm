package Beaver::Bootstrap3::Widget::Form;
use Mojo::Base 'Beaver::Bootstrap3::Widget';
use Mojo::ByteStream 'b';
use Mojo::Util qw(xml_escape);
use Data::Dumper;

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self->attrs->{class} = $self->oid;
    $self->attrs->{'data-action'} = xml_escape($self->props->{action}) if $self->props->{action};
    $self;
}

sub field {
    my ($self, $el) = @_;
    if (ref $el->[0] eq 'ARRAY') {
        return b $self->app->widget('row', sub {return b join('', map {$self->field($_)} @$el)});
    }
    else {
        map {
            if (ref $_ eq 'HASH') {
                $_->{-form} ||= $self->oid;
            }
        } @$el;
        return b $self->app->widget(@$el);
    }
}

1;

__DATA__

@@ widgets/form.html.ep
<div class="container-fluid pt-20">
<form <%= $wg->pack_attrs %>></form>
%   for my $el (@{ $wg->props->{fields}||[] }) {
<%= $wg->field($el) %>
%   }
%= $wg->content
</div>
% js_onload begin

% end
