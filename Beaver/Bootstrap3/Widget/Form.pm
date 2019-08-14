package Beaver::Bootstrap3::Widget::Form;

use Mojo::Base 'Beaver::Bootstrap3::Widget';
use Mojo::ByteStream 'b';
use Mojo::Collection;
use Mojo::Util qw(xml_escape);
use List::Util qw(any);

use Data::Dumper;

has buttons => sub {new Mojo::Collection};

sub init {
    my $self = shift;
    $self->SUPER::init(@_);

    push @{ $self->buttons }, grep {
        ref $$_{-hide} ? $$_{-hide}->($self->c) : exists $$_{-hide} ? !$$_{-hide} : 1
    } grep {
        ref $$_{-show} ? $$_{-show}->($self->c) : exists $$_{-show} ? $$_{-show} : 1
    } grep {
        @{ $$_{-actions}||[] } ? any { $self->c->action eq $_ } @{ $$_{-actions}||[] } : 1
    }  @{ $self->props->{buttons}||[] };
    
    $self;
}

sub field {
    my ($self, $el, $readonly) = @_;
    if (ref $el->[0] eq 'ARRAY') {
        b $self->c->widget('row', sub {return b join('', map {$self->field($_, $readonly)} @$el)});
    }
    else {
        map {
            if (ref $_ eq 'HASH') {
                $_->{-readonly} = $readonly;
                $_->{value} = $self->props->{data}{$_->{name}};
            }
        } @$el;
        b $self->c->widget(@$el);
    }
}

1;

=encoding utf8

=head1 NAME

Beaver::Bootstrap3::Widget::Form - form widget

=head1 SYNOPSIS

  <%= widget form => {
    -label      => 'Edit record',
    -buttons    => [
        {
            -default    => 'update',
            -actions    => [qw(edit)]
        },
        {
            -default    => 'edit',
            -actions    => [qw(item)]
        },
        {
            -tag        => 'a',
            -context    => 'danger',
            href        => sub { join '/', '', $_[0]->entity, ($_[0]->action eq 'edit' ? $_[0]->id : ()) },
            -label      => 'Cancel',
            -actions    => [qw(item edit)]
        },
    ],
    -fields     => [
        [
            form-input => {
                name    => 'label',
                _form   => [qw(form-update)],
            },
        ],
    ],
  } => begin %>Correct and save<% end %>

=head1 DESCRIPTION

L<Beaver::Bootstrap3::Widget::Form> provides pseudo-form component widget backend for L<Beaver::Plugin::Widgets>.
Pseudo-form is area with title, set of buttons and set of fields. This is not real form. Submit form creates on
the fly on button click events.

=head1 PROPERTIES

L<Beaver::Bootstrap3::Widget::Form> implements following properties.

=head2 buttons

  <%= widget form => {
    -buttons    => [
        {
            predefined  => 'login',
        },
        {
            predefined  => 'register',
        },
        {
            predefined  => 'remind',
        },
    ],
  } => begin %>Authorization<% end %>

Set of buttons which will be displayed on the top row of form.

=head1 SEE ALSO

L<Mojolicious>, L<Beaver::Plugin::Widgets>.

=cut
__DATA__

@@ widgets/form.html.ep
<div class="container-fluid pt-20">
    <div class="row">
       <div class="col-md-4">
%   if ($wg->props->{label}) {
<h4><%= $wg->props->{label} %></h4>
%   }
        </div>
        <div class="col-md-8 text-right">
%   for my $btn ($wg->buttons->each) {
<%= widget button => ($btn) %>
%   }
        </div>
    </div>

%   for my $el (@{ $wg->props->{fields} || [] }) {
<%= $wg->field($el, $wg->props->{readonly}) %>
%   }

    <div class="row">
        <div class="col-md-12">
<%= $wg->content %>
        </div>
    </div>
</div>

