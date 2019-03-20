package Beaver::Plugin::Connector; 
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Loader 'load_class';
use Carp 'croak';

has [qw(connectors drivers)] => sub {{}};

sub register {
    my ($self, $app, $conf) = @_;
    
    $app->helper('connect' => sub {
        my ($c, $backend) = @_;
        if (!exists $self->connectors->{$backend}) {
            my $dsn = $app->config->{beaver}{backends}{$backend} || croak "Backend '$backend' is not defined in beaver.conf";
            my $module;
            for ($dsn) {
                $module = 'Mojo::Pg',     last if $dsn =~ /^pg:/;
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

