package Beaver::Plugin::Widgets;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(xml_escape camelize);
use Mojo::ByteStream;
use Session::Token;

use Data::Dumper;

has cfg => sub {{}};
has ['app'];
has ['modules', 'refs'] => sub {{}};

# object ID generator
has token_generator => sub {
    my $token = Session::Token->new(alphabet => [0..9,'a'..'z'], length => 8);
    sub { 'js-' . unpack('h8', pack('l', time)) . $token->get }
};

sub register {
    my ($self, $app, $conf) = @_;

    $self->app($app);
    $self->cfg({ %{ $self->cfg }, %{ $app->config->{beaver}{widgets} || {} }, %{ $conf || {} } });
    # static content
    if (my $modules = $self->cfg->{static}) {
        my @modules = ref $modules ? @$modules : ($modules);
        push @{$self->app->static->classes}, @modules;
        for my $module (@modules) {
            $module =~ s/::/\//g;
            require "$module.pm";
        }
        $self->app->static->warmup;
    }

    # Helpers
    # widget call itself
    $app->helper(widget => sub {
        my ($c, $name, @param) = @_;
        my ($vars, $conf, $content, $ref) = ({}, [], undef, undef);
        for (@param) {
            $vars       = $_, next if ref $_ eq 'HASH';
            $conf       = $_, next if ref $_ eq 'ARRAY';
            $content    = $_, next if ref $_ eq 'CODE';
            $ref        = $_, next if !ref $_;
        }

        my $wg = $self->create_self($name, $vars);
        $self->refs->{$ref} = $wg if $ref;
        $wg->content($content->($wg, $vars)) if $content && $wg->can('content');
        $c->stash(
            vars => $vars,
            wg => $wg,
        )->render_to_string(
            "widgets/$name"
        );
    });

    # adding js snippets to document onload (jQuery is expected in frontend)
    $app->helper(js_onload => sub {
        my ($c, $content) = @_;
        my $code = $c->stash('widget.jsonload') || [];
        if ($content) {
            $c->stash('widget.jsonload' => [@$code, $content->()]);
        }
        elsif (~~@$code) {
            return Mojo::ByteStream->new("<script>\n\$(function(){\n" . join("\n;\n", @$code) . "\n})\n</script>");
        }
        "";
    });

    # object ID generator for unique internal DOM ids
    $app->helper(generate_token => sub {
        $self->token_generator->();
    });

    # widget by ref
    $app->helper(widget_by_ref => sub {
        $self->refs->{$_[1]};
    });

    $self;
}

sub create_self {
    my ($self, $name, $vars) = @_;
    if (!$self->modules->{$name}) {
        my $module = (
            $self->modules->{$name} = join('::', $self->cfg->{namespace} || ref($self->app), 'Widget', camelize($name))
        );
        $module =~ s/::/\//g;
        require "$module.pm";
        push @{$self->app->renderer->classes}, $self->modules->{$name};
        $self->app->renderer->warmup;
    }
    $self->modules->{$name}->new($self->app, $vars);
}

1;

__END__
