package Beaver::Bootstrap3::Widget;

use Mojo::Base -base;
use Mojo::Util qw(xml_escape decamelize);
use Mojo::ByteStream;
use Mojo::Loader qw(data_section);
use Data::Dumper;

has ['attrs', 'props', 'templates'] => sub {{}};
has ['app', 'c', 'oid', 'content'];

sub new {
    my ($class, $app, $c) = splice(@_, 0, 3);
    my $self = $class->SUPER::new(@_);
    $self->app($app);
    $self->c($c);
    $self->init(@_);
    return $self;
}

sub init {
    my ($self, $args) = splice(@_, 0, 2);
    $args = { $args, @_ } if !ref $args;
    if ($args->{-default}) {
        $args = {%{ $self->defaults->{ $args->{-default} }||{} }, %$args};
        delete $args->{-default};
    }
    /^-(\S+)$/ ? $self->props->{$1} : /^_(\S+)$/ ? $self->attrs->{'data-'.$1} : $self->attrs->{$_} = ref $args->{$_} eq 'CODE' ? $args->{$_}->($self->c) : $args->{$_} for keys %$args;
    $self->oid($self->props->{oid} || $self->app->generate_token);
    $self->attrs->{class} = [split(/\s+/, $self->attrs->{class})] if $self->attrs->{class} && !ref $self->attrs->{class};
    $self;
}

sub defaults {{}}

sub pack_attrs {
    my ($self, $attrs, $space) = @_;
    $attrs ||= $self->attrs;
    return Mojo::ByteStream->new(
        ($space//'') . join(' ', map { "$_=\"" . xml_escape(ref($attrs->{$_}) eq 'ARRAY' ? join(' ', @{ $attrs->{$_} }) : $attrs->{$_}) . "\"" } keys %$attrs)
    );
}

sub icon {
    my ($self, $icon) = @_;
    for ($icon || []) {
        return $self->app->fas(@$icon[1..@$icon-1]) if $$icon[0] eq 'fas';
        return $self->app->far(@$icon[1..@$icon-1]) if $$icon[0] eq 'far';
        return $self->app->fab(@$icon[1..@$icon-1]) if $$icon[0] eq 'fab';
        return $self->app->fal(@$icon[1..@$icon-1]) if $$icon[0] eq 'fal';
        return $self->app->fa_layers(@$icon[1..@$icon-1]) if $$icon[0] eq 'fa_layers';
    }
    return '';
}

1;

