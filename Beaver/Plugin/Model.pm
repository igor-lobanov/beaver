package Beaver::Plugin::Model; 
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Loader 'load_class';
use Mojo::Util 'camelize';
use Carp 'croak';

use Data::Dumper;

has [qw(app)];
has [qw(models connectors drivers)] => sub {{}};

sub register {
    my ($self, $app, $conf) = @_;
    $self->app($app); 
   
    $app->helper('load_model' => sub {
        my ($c, $entity) = @_;
        if (!exists $self->models->{$entity}) {
            my $module = ref($c->app) . '::Model::' . camelize($entity);
            my $e = load_class $module;
            croak ref $e ? $e : qq{Model '$entity' module '$module' loading error} if $e;
            $self->models->{$entity} = $module;
        }
        $self->models->{$entity}->new(
            app     => $self->app,
            entity  => $entity,
            c       => $c,
        );
    });

    $app->helper('connect' => sub {
        my ($c, $backend) = @_;
        if (!exists $self->connectors->{$backend}) {
            my $dsn = $app->config->{beaver}{backends}{$backend} || croak "Backend '$backend' is not defined in beaver.conf";
            my $module;
            for ($dsn) {
                $module = 'Mojo::Pg',     last if $dsn =~ /^postgres:/;
                $module = 'Mojo::mysql',  last if $dsn =~ /^mysql:/;
                $module = 'Mojo::SQLite', last if $dsn =~ /^sqlite:/;
            }
            if (!$self->drivers->{$module}) {
                if (my $e = load_class $module) {
                    croak ref $e ? $e : qq{Error loading driver module '$module' for backend '$backend'};
                }
                else {
                    $self->drivers->{$module}++;
                }
            }
            $self->connectors->{$backend} = $module->new($dsn);
        }
        $self->connectors->{$backend};
    });

    $self;
}

1;
