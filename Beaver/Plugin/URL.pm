package Beaver::Plugin::URL;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Parameters;
use Mojo::Util qw(xml_escape);

use Data::Dumper;

has cfg => sub {{}};
has ['app'];

sub register {
    my ($self, $app, $conf) = @_;

    $self->app($app);
    $self->cfg({ %{ $self->cfg }, %{ $conf || {} } });

    # Helpers
    # Build URI
    # resulting URI /users/1000/edit
    # $c->build_uri({entity => 'users', id => 1000, action => 'edit'})
    # /users/1000/edit
    # current URI /users/1000/edit
    # result URI /users/1000
    # $c->build_uri({entity => 'users', id => 1000, action => undef})
    # current URI /users/1000/edit
    # result URI /users/export
    # $c->build_uri({entity => 'users', id => undef, action => 'export'})
    $app->helper(build_uri => sub {
        my $c = shift;
        my $param = ref $_[0] eq 'HASH' ? $_[0] : {@_};
        join '/', '',
            exists $param->{entity}
            ? (defined $param->{entity} ? $param->{entity} : $self->cfg->{beaver}{default_entity})
            : $c->entity || $self->cfg->{beaver}{default_entity},
            exists $param->{id}
            ? (defined $param->{id} ? $param->{id} : ())
            : ($c->id ? $c->id : ()),
            exists $param->{action}
            ? (defined $param->{action} ? $param->{action} : ())
            : ($c->action && $c->action !~ /^(?:item|list)$/ ? $c->action : ())
    });
    $app->helper(build_query_string => sub {
        my $c = shift;
        
        my ($params, $options) = _args(@_);
        
        my $parameters = Mojo::Parameters->new(my %new = (
            (map {$_ => $c->req->params->param($_) } grep /\./, @{ $c->req->params->names }),
            %$params
        ));
        return "$parameters" if !$options->{-hidden};

        my $attrs = ref $options->{-hidden} eq 'HASH'
            ? join(' ', map {qq{@{[ xml_escape $_ ]}="@{[ xml_escape $options->{-hidden}{$_} ]}"}} keys %{$options->{-hidden}})
            : '';
        my @inputs;
        for my $p (@{ $parameters->names }) {
            push @inputs, qq{<input type="hidden" $attrs name="@{[ xml_escape $p ]}" value="@{[ xml_escape $parameters->param($p) ]}">};
        }
        return join '', @inputs;
    });

    $self;
}

sub _args {
    my %args;
    for (@_) {
        if (ref $_ eq 'HASH') {
            %args = (%args, %$_);
        }
        elsif (!ref $_) {
            %args = (%args, %{ Mojo::Parameters->new($_)->to_hash })
        }
    }
    return (
        { map {$_ => $args{$_}} grep /\./, grep !/^-/, keys %args },
        { map {$_ => $args{$_}} grep /^-/, keys %args }
    );
}

1;

__END__
