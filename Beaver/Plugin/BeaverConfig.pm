package Beaver::Plugin::BeaverConfig;
use Mojo::Base 'Mojolicious::Plugin::Config';

sub register {
    my ($self, $app, $conf) = @_;
    my $config = $self->SUPER::register($app);
    $config->{beaver} = { %{ $conf || {} }, %{ $config->{beaver} || {} } };
    $app->config($config)->config;
}

1;
