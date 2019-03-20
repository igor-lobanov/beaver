package Beaver::Define;
use strict;
use warnings;
use Mojo::Util 'monkey_patch';

# define action => action1 => ['PUT'] => sub {}
# _action_PUT_action1
# define check => action1 => ['GET'] => sub {}
# _check_GET_action1
# define access => action1 => ['OPTIONS', 'HEAD'] => sub {}
# _access_OPTIONS_action1
# _access_HEAD_action1

sub import {
    my ($class, $caller) = (shift, caller);
    monkey_patch($caller, 'define',  sub { __define($caller, @_) });
}

sub __define {
    my ($self, $type) = splice(@_, 0, 2);
    return unless (my $class = ref $self || $self);
    return if $type !~ /^(?:action|check|access)$/;
    my ($act, $methods, $sub) = (undef, ['ANY'], sub {$_[0]->render});
    for (@_) {
        $act = $_ if !ref $_;
        $methods = $_ if ref $_ eq 'ARRAY';
        $sub = $_ if ref $_ eq 'CODE';
    }
    return if $act !~ /^[a-z0-9]+$/;
    $methods ||= ['ANY'];
    monkey_patch($class, __subname($type, $_, $act), $sub) for @$methods;
}

sub __subname {join('_', '', @_)}

1;

