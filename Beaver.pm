package Beaver;

use Mojo::Base 'Mojolicious';
use Mojo::Log;
use Beaver::Controller;
use Data::Dumper;

# This method will run once at server start
sub startup {
    my $app = shift;

    $app->moniker('beaver');
    $app->controller_class('Beaver::Controller');
    push @{$app->plugins->namespaces}, 'Beaver::Plugin';

    $app->plugin('BeaverConfig', {
        fontawesome     => 1,
        widgets         => {
            namespace   => 'Beaver::Bootstrap3',
            static      => [qw(
                Beaver::Bootstrap3::Static::Widget
            )],
        },
        asset_loader    => {
            js_path   => $app->home . '/public/js/cache',
            js_url    => '/js/cache',
            css_path  => $app->home . '/public/css/cache',
            css_url   => '/css/cache',
        },
        default_controller    => 'root',
    });
    my $bconf = $app->config->{beaver};

    $app->log(Mojo::Log->new(path => $app->home . '/log/http.log', level => 'debug')) if -e $app->home . '/log/';
    $app->plugin('Fontawesome');
    $app->plugin('Widgets', $bconf->{widgets}) if $bconf->{widgets};
    $app->plugin('AssetLoader', $bconf->{asset_loader}) if $bconf->{asset_loader};
    $app->plugin('Model');

    # main routing engine
    my $re_controller = qr/[a-z][a-z0-9_-]{3,}/;
    my $re_action     = qr/[a-z][a-z0-9_]*/;
    my %to = (controller => $bconf->{default_controller}, action => 'Handler');
    $app->routes->any('/')->to(%to);
    $app->routes->any('/:controller' => [controller => qr/$re_controller/])->to(%to);
    $app->routes->any('/:controller/:sub' => [controller => qr/$re_controller/, sub => qr/$re_action/])->to(%to);
    $app->routes->any('/:controller/<id:num>' => [controller => qr/$re_controller/])->to(%to);
    $app->routes->any('/:controller/<id:num>/:sub' => [controller => qr/$re_controller/, sub => qr/$re_action/])->to(%to);

}

1;

__DATA__

