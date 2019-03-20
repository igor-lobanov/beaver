package Beaver::Controller;
use Mojo::Base 'Mojolicious::Controller';

use Beaver::Data;

use Data::Dumper;

has [qw(entity action id portion start model)];
has data => sub {new Beaver::Data};

# If controller have not model backend it must be modelless
# By default we wait that controller have model
has modelless => 0;
# Destination action after create executing
has after_create => 'edit';

my $method_sub_map = {
    GET     => {
        1   => 'item',
        0   => 'list',
    },
    POST    => {
        1   => 'update',
        0   => 'create',
    },
    PUT     => {
        1   => 'update',
    },
    DELETE  => {
        1   => 'delete',
    },
    PATCH   => {
        1   => 'update',
    },
};

sub Handler {
    my $c = shift;

    $c->entity($c->stash('controller'));
    $c->id($c->stash('id')) if $c->stash('id');

    # /:controller[/:id] sub autoselect by HTTP method and id presence in URL
    if (!$c->stash('sub') && (my $sub = $method_sub_map->{$c->req->method}{$c->id ? 1 : 0})) {
        $c->stash('sub' => $sub);
    }

    return $c->reply->not_found if !$c->stash('sub');
    $c->action($c->stash('sub'));

    $c->model($c->load_model($c->entity)) if !$c->modelless;

    # check access
    if (my $sub = $c->can($c->req->method . '_access_' . $c->action) || $c->can('_access_' . $c->action)) {
        return $c->rendered(403) if !$sub->($c);
    }

    # validate
    if (my $sub = $c->can($c->req->method . '_validate_' . $c->action) || $c->can('_validate_' . $c->action)) {
        my $errors = $sub->($c);
        return $c->render(json => $errors) if $errors;
    }

    # execute
    if (my $sub = $c->can($c->req->method . '_' . $c->action) || $c->can($c->action)) {
        $c->stash(action => $c->action);
        return $sub->($c);
    }

    $c->reply->not_found;
}

# Default actions
sub item {
    my $c = shift;
    $c->stash(_d => $c->model->item) if !$c->modelless;
}

# item editing form
sub edit {
    my $c = shift;
    $c->item;
}

sub list {
    my $c = shift;
    $c->stash(_d => $c->model->list) if !$c->modelless;
}

sub create {
    my $c = shift;
    if (!$c->modelless) {
        if (my $id = $c->model->create) {
            return $c->redirect_to('/' . $c->entity . '/' . $id . ($c->after_create ? '/' . $c->after_create : ''));
        }
        else {
            return $c->rendered(500);
        }
    }
}

sub update {
    my $c = shift;
    $c->model->update(map {$_ => $c->param($_)} keys %{ $c->model->schema->fields || {} }) if !$c->modelless;
    return $c->redirect_to('/' . $c->entity . '/' . $c->id);
}

sub delete {
    my $c = shift;
    $c->model->delete if !$c->modelless
}

1;

