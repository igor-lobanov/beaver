package Beaver::Plugin::AssetLoader; 
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(hmac_sha1_sum);
use Mojo::Asset::File;
use Data::Dumper;

has [qw(cache cfg)] => sub {{}};
has [qw(app)];

sub register {
    my ($self, $app, $conf) = @_;
    $self->app($app); 
    $self->cfg({
        -d $app->static->paths->[0] . '/cache' ? (
            js_path     => $app->static->paths->[0] . '/cache',
            css_path    => $app->static->paths->[0] . '/cache',
            js_url      => '/cache',
            css_url     => '/cache',
        ) : (
            js_path     => $app->static->paths->[0],
            css_path    => $app->static->paths->[0],
            js_url      => '',
            css_url     => '',
        ),
        %{ $app->config->{beaver}{asset_loader} || {} },
        %{ $conf || {} },
    });
    $app->helper('js_load' => sub {
        my ($c, $files) = @_;
        $files = [$files, @_[2..@_-1]] if !ref $files;
        my $checksum = hmac_sha1_sum(join('', @$files));
        if (!$self->cache->{$checksum} || !-e $self->cfg->{js_path} . "/" . $self->cache->{$checksum}) {
            my $output = Mojo::Asset::File->new;
            for my $file (@$files) {
                next if $file =~ /^#/;
                if (my $asset = $app->static->file($file)) {
                    $output->add_chunk($asset->slurp . "\n;\n");
                }
                else {
                    $app->log->error(sprintf('File %s not found', $file));
                }
            }
            $output->move_to($self->cfg->{js_path} . "/$checksum.js");
            $self->cache->{$checksum} = "$checksum.js";
        }
        return $self->cfg->{js_url} . "/" . $self->cache->{$checksum};
    });

    $app->helper('css_load' => sub {
        my ($c, $files) = @_;
        $files = [$files, @_[2..@_-1]] if !ref $files;
        my $checksum = hmac_sha1_sum(join('', @$files));
        if (!$self->cache->{$checksum} || !-e $self->cfg->{css_path} . "/" . $self->cache->{$checksum}) {
            my $output = Mojo::Asset::File->new;
            for my $file (@$files) {
                next if $file =~ /^#/;
                if (my $asset = $app->static->file($file)) {
                    $output->add_chunk($asset->slurp . "\n");
                }
                else {
                    $app->log->error(sprintf('File %s not found', $file));
                }
            }
            $output->move_to($self->cfg->{css_path} . "/$checksum.css");
            $self->cache->{$checksum} = "$checksum.css";
        }
        return $self->cfg->{css_url} . "/" . $self->cache->{$checksum};
    });

    $self;
}

1;

__END__
