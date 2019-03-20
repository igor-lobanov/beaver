package Beaver::Plugin::Fontawesome;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::ByteStream qw(b);
use Mojo::Util qw(xml_escape);

has ['app'];

sub register {
    my ($self, $app, $conf) = @_;

    $self->app($app);

    # Helpers
    sub fa {
        my ($fa_style, $c, @param) = @_;
        my ($tune, $icon) = ({}, '');
        for (@param) {
            $tune = $_, next if ref $_ eq 'HASH';
            $icon = $_, next if !ref $_;
        }
        $tune ||= {};
        $$tune{size} .= 'x' if defined $$tune{size} && $$tune{size} =~ /^\d+$/;
        my @class = (
            $fa_style,
            "fa-$icon",
            ($$tune{fixed} ? 'fa-fw' : ()),
            ($$tune{size} ? "fa-$$tune{size}" : ()),
            (map { ($$tune{$_} ? "fa-$_" : ()) } qw(inverse spin pulse)),
            ($$tune{class} ? $$tune{class} : ()),
        );
        my @style = (
            ($$tune{color} ? "color:$$tune{color}" : ()),
            ($$tune{bgcolor} ? "background:$$tune{bgcolor}" : ()),
        );
        my @transform = (
            (map { ($$tune{$_} ? "$_-$$tune{$_}" : ()) } qw(shrink grow left right up down rotate)),
            ($$tune{flipv} ? 'flip-v' : ()),
            ($$tune{fliph} ? 'flip-h' : ()),
        );
        my @attrs = (
            qq{class="@{[ join(' ', map {xml_escape($_)} @class) ]}"},
            (~~@style ? qq{style="@{[ join(';', map {xml_escape($_)} @style) ]}"} : ()),
            (~~@transform ? qq{data-fa-transform="@{[ join(' ', map {xml_escape($_)} @transform) ]}"} : ()),
            ($$tune{mask} ? qq{data-fa-mask="@{[ xml_escape($$tune{mask}) ]}"} : ()),
            ($$tune{id} ? qq{id="@{[ xml_escape($$tune{id}) ]}"} : ()),
        );

        return b qq{<span @{[ join(' ', @attrs) ]}></span>};
    };

    for my $st (qw(fas far fab fal)) {
        $app->helper($st => sub { fa $st, @_ });
    }

    $app->helper(fa_layers => sub {
        my ($c, @param) = @_;
        my ($tune, $icons) = ({}, []);
        for (@param) {
            $tune  = $_, next if ref $_ eq 'HASH';
            $icons = $_, next if ref $_ eq 'ARRAY';
        }
        $tune ||= {};
        $$tune{size} .= 'x' if defined $$tune{size} && $$tune{size} =~ /^\d+$/;
        my @class = (
            'fa-layers',
            ($$tune{fixed} ? 'fa-fw' : ()),
            ($$tune{class} ? $$tune{class} : ()),
        );
        my @style = (
            ($$tune{color} ? "color:$$tune{color}" : ()),
            ($$tune{bgcolor} ? "background:$$tune{bgcolor}" : ()),
        );
        my @attrs = (
            qq{class="@{[ join(' ', map {xml_escape($_)} @class) ]}"},
            (~~@style ? qq{style="@{[ join(';', map {xml_escape($_)} @style) ]}"} : ()),
            ($$tune{id} ? qq{id="@{[ xml_escape($$tune{id}) ]}"} : ()),
        );
        my ($pre, $post) = $$tune{size} ? (qq{<span class="fa-@{[ xml_escape($$tune{size}) ]}">}, qq{</span>}) : ('', '');
        return b $pre . qq{<span @{[ join(' ', @attrs) ]}>@{[ join('', @$icons) ]}</span>} . $post;
    });

    $app->helper(fa_counter => sub {
        my ($c, @param) = @_;
        my ($tune, $count) = ({}, 0);
        for (@param) {
            $tune  = $_, next if ref $_ eq 'HASH';
            $count = $_, next if !ref $_;
        }
        my @class = (
            'fa-layers-counter',
            ($$tune{class} ? $$tune{class} : ()),
            (map { $$tune{$_} ? "fa-layers-$_" : () } qw(bottom-left bottom-right top-left top-right)),
        );
        my @style = (
            ($$tune{color} ? "color:$$tune{color}" : ()),
            ($$tune{bgcolor} ? "background:$$tune{bgcolor}" : ()),
        );
        my @attrs = (
            qq{class="@{[ join(' ', map {xml_escape($_)} @class) ]}"},
            (~~@style ? qq{style="@{[ join(';', map {xml_escape($_)} @style) ]}"} : ()),
            ($$tune{id} ? qq{id="@{[ xml_escape($$tune{id}) ]}"} : ()),
        );
        return b qq{<span @{[ join(' ', @attrs) ]}>$count</span>};
    });

    $app->helper(fa_text => sub {
        my ($c, @param) = @_;
        my ($tune, $text) = ({}, '');
        for (@param) {
            $tune  = $_, next if ref $_ eq 'HASH';
            $text = $_, next if !ref $_;
        }
        my @class = (
            "fa-layers-text",
            ($$tune{class} ? $$tune{class} : ()),
        );
        my @style = (
            ($$tune{color} ? "color:$$tune{color}" : ()),
            ($$tune{bgcolor} ? "background:$$tune{bgcolor}" : ()),
        );
        my @transform = (
            (map { $$tune{$_} ? "$_-$$tune{$_}" : () } qw(shrink grow left right up down rotate)),
            ($$tune{flipv} ? 'flip-v' : ()),
            ($$tune{fliph} ? 'flip-h' : ()),
        );
        my @attrs = (
            qq{class="@{[ join(' ', map {xml_escape($_)} @class) ]}"},
            (~~@style ? qq{style="@{[ join(';', map {xml_escape($_)} @style) ]}"} : ()),
            (~~@transform ? qq{data-fa-transform="@{[ join(' ', map {xml_escape($_)} @transform) ]}"} : ()),
            ($$tune{id} ? qq{id="@{[ xml_escape($$tune{id}) ]}"} : ()),
        );

        return b qq{<span @{[ join(' ', @attrs) ]}>@{[ xml_escape($text) ]}</span>};
    });

    $self;
}

1;

=encoding utf8

=head1 NAME

MojoX::Plugin::Fontawesome - plugin to add fontawesome snippets in templates.

=head1 SYNOPSIS

    <head>
    <!-- Add fontawesome JS support on your page -->
    <script defer src="https://use.fontawesome.com/releases/v5.6.3/js/all.js"
        integrity="sha384-EIHISlAOj4zgYieurP0SdoiBYfGJKkgWedPHH4jCzpCXLmzVsw1ouK59MuUtP4a1"
        crossorigin="anonymous"></script>
    </head>

    <%= fab ubuntu => {color => 'orange', size => '3x', spin => 1} %>

    <%= fa_layers {fixed => 1} => [
        (fas 'cannabis' => {color => 'green'}),
        (fas 'ban' => {color => 'red', grow => 12, spin => 1}),
    ] %>

    <%= fa_layers {size => '3x'} => [
        (fas 'envelope' => {color => 'red'}),
        (fa_counter 1202 => {color => 'white', bgcolor => 'orange', 'bottom-right' => 1}),
    ] %>

=head1 DESCRIPTION

L<MojoX::Plugin::Fontawesome> provides helpers for easy adding Fontawesome 5 snippets to templates.

=head1 HELPERS

L<MojoX::Plugin::Fontawesome> implements following helpers. B<fas>, B<fab>, B<far>, B<fal> are simplest
snippets for one of Fontawesome 5 styles: B<solid>, B<brands>, B<regular>, B<light>. This helpers are fully
identical. The only difference is resulting class in fontawesome snippet.

=head2 fab

Adds fontawesome icon from B<brand> style.

    <%= fab ubuntu => {color => 'orange', size => '3x', spin => 1} %>

Resulting HTML:

    <span class="fab fa-ubuntu fa-3x fa-spin" style="color:orange"></span>

Hash keys adds some properties to resulting code.

=over

=item class

Adds custom class(es) to icon class attribute. To add more then one class separate them with space.

    <%= fab ubuntu => {class => 'active open', color => 'orange', size => 3, spin => 1} %>

Result:

    <span class="fab fa-ubuntu fa-3x fa-spin active open" style="color:orange"></span>

=item id

Adds id attribute to icon.

    <%= fab ubuntu => {id => 'ubuntu-icon', color => 'orange', size => 3, spin => 1} %>

Result:

    <span class="fab fa-ubuntu fa-3x fa-spin" style="color:orange" id="ubuntu-icon"></span>

=item color

Sets color of icon via css B<color> in style attribute.

=item bgcolor

Sets background color of icon via css B<background> in style attribute.

=item fixed

Sets fixed width to icon.

=item size

Makes icon larger in N times.

=item inverse

Inverts icon.

=item spin

Makes icon rotate.

=item pulse

Makes icon rotate by steps.

=item shrink

Value of parameter is number. Adds transformation (B<data-fa-transformation> attribute) shrink-N to icon. Makes icon smaller.
This feature requires JS version of Fontawesome5.

=item grow

Value of parameter is number. Adds transformation grow-N to icon. Makes icon larger.
This feature requires JS version of Fontawesome5.

=item left

Value of parameter is number. Adds transformation left-N to icon. Moves icon left.
This feature requires JS version of Fontawesome5.

=item right

Value of parameter is number. Adds transformation right-N to icon. Moves icon right.
This feature requires JS version of Fontawesome5.

=item up

Value of parameter is number. Adds transformation up-N to icon. Moves icon up.
This feature requires JS version of Fontawesome5.

=item down

Value of parameter is number. Adds transformation down-N to icon. Moves icon down.
This feature requires JS version of Fontawesome5.

=item rotate

Value of parameter is number of degrees. Negative value means backclock rotation. Adds transformation rotate-N to icon. Rotate icon on N degrees.
This feature requires JS version of Fontawesome5.

=item flipv

Flips icon vertically.
This feature requires JS version of Fontawesome5.

=item fliph

Flips icon horizontally.
This feature requires JS version of Fontawesome5.

=item mask

Adds mask data attribute to icon (data-fa-mask). Used for masking one icon by another.
This feature requires JS version of Fontawesome5.

    <%= fas 'pencil-alt' => { mask => 'fas fa-comment', shrink => 10, up => 0.5 } %>

Result:

    <span class="fas fa-pencil-alt" data-fa-transform="shrink-10 up-0.5" data-fa-mask="fas fa-comment"></span>

=back

=head2 far

Adds fontawesome regular icon. See B<fab> for options.

=head2 fal

Adds fontawesome light icon. See B<fab> for options.

=head2 fas

Adds fontawesome solid icon. See B<fab> for options.

=head2 fa_layers

New feature in Fontawesome 5 which allows to organize single icons in layered stack. This allows to build new icons and add new properties to them.
Helper takes 2 arguments hash ref with options and array ref with stack elements. Usually stack element is just result of one of single icon helpers
or one of 2 special helpers B<fa_counter> and B<fa_text>.
This feature requires JS version of Fontawesome 5.

    <%= fa_layers {size => 4, fixed => 1} => [
        (fas 'comment'),
        (fa_text 'Hello' => {color => 'white', shrink => 12}),
    ] %>


Resulting snippet will contain Fontawesome layer stack with 2 elements - icon B<comment> and text 'Hello' over it. Take elements in brackets
to prevent adding next element to argument list of previous one.

    <span class="fa-4x">
        <span class="fa-layers fa-fw">
            <span class="fas fa-comment"></span>
            <span class="fa-layers-text" style="color:white" data-fa-transform="shrink-12">Hello</span>
        </span>
    </span>

This hellper supports such options.

=over

=item class

Adds custom class(es) to layer's class attribute. To add more then one class separate them with space.

    <%= fa_layers {size => 4, fixed => 1, class => 'disabled'} => [
        (fas 'comment'),
    ] %>

Result:

    <span class="fa-4x">
        <span class="fa-layers fa-fw disabled">
            <span class="fas fa-comment"></span>
        </span>
    </span>

=item id

Adds id attribute to layer.

    <%= fa_layers {size => 4, fixed => 1, id => 'comment-icon-layer'} => [
        (fas 'comment'),
    ] %>

Result:

    <span class="fa-4x">
        <span class="fa-layers fa-fw" id="comment-icon-layer">
            <span class="fas fa-comment"></span>
        </span>
    </span>

=item size

Sets size of layer stack.

=item fixed

Makes layer width fixed.

=item color

Sets color of layer via css B<color> in style attribute.

=item bgcolor

Sets background color of layer via css B<background> in style attribute.

=back

=head2 fa_counter

This helper used in fa_layers stacks to display counter badge in the corner of stacked icons.
This hellper supports such options.

=over

=item class

Adds custom class(es) to counter class attribute. To add more then one class separate them with space.

    <%= fa_counter 123 => {class => 'extreme-value'} %>

Result:

    <span class="fa-layers-counter extreme-value">123</span>

=item id

Adds id attribute to counter.

    <%= fa_counter 123 => {id => 'comment-counter'} %>

Result:

    <span class="fa-layers-counter" id="comment-counter">123</span>

=item color

Badge text color via css B<color> in B<style> attribute.

=item bgcolor

Badge background color via css B<background> in B<style> attribute.

=item bottom-left

Positions badge in the bottom left corner.

=item bottom-right

Positions badge in the bottom right corner.

=item top-left

Positions badge in the top left corner.

=item top-right

Positions badge in the top right corner (default position).

=back

=head2 fa_text

This helper used in fa_layers stacks to display text over icons.
This hellper supports such options.

=over

=item class

Adds custom class(es) to text class attribute. To add more then one class separate them with space.

    <%= fa_text 'New' => {class => 'js-text-label'} %>

Result:

    <span class="fa-layers-text js-text-label">New</span>

=item id

Adds id attribute to text.

    <%= fa_text 'Expired' => {id => 'text-label-id'} %>

Result:

    <span class="fa-layers-text" id="text-label-id">Expired</span>

=item color

Sets color of text via css B<color> in style attribute.

=item bgcolor

Sets background color of text via css B<background> in style attribute.

=item shrink

Value of parameter is number. Adds transformation (B<data-fa-transformation> attribute) shrink-N to text. Makes text smaller.

=item grow

Value of parameter is number. Adds transformation grow-N to text. Makes text larger.

=item left

Value of parameter is number. Adds transformation left-N to text. Moves text left.

=item right

Value of parameter is number. Adds transformation right-N to text. Moves text right.

=item up

Value of parameter is number. Adds transformation up-N to text. Moves text up.

=item down

Value of parameter is number. Adds transformation down-N to text. Moves text down.

=item rotate

Value of parameter is number of degrees. Negative value means backclock rotation. Adds transformation rotate-N to text. Rotate text on N degrees.

=item flipv

Flips text vertically.

=item fliph

Flips text horizontally.

=back

=head1 SEE ALSO

L<Mojolicious>, L<https://fontawesome.com>.

=cut

