package Beaver::Controller;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON qw(decode_json);

use Data::Dumper;

has [qw(entity action id portion start model sid)];
has data => sub {{}};

# If controller have not model backend it must be modelless
# By default we wait that controller have model
has modelless => 0;
# Destination action after create executing
has after_create => 'edit';
has after_update => '';

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

    # setup entity and id of request
    $c->entity($c->stash('controller'));
    $c->id($c->stash('id')) if $c->stash('id');

    # /:controller[/:id] sub autoselect by HTTP method and id presence in URL
    if (!$c->stash('sub') && (my $sub = $method_sub_map->{$c->req->method}{$c->id ? 1 : 0})) {
        $c->stash('sub' => $sub);
    }

    # setup action
    return $c->reply->not_found if !$c->stash('sub');
    $c->action($c->stash('sub'));

    # request parameters
    my $data = {
        %{ $c->req->params->to_hash || {} },
        %{ $c->req->json || {} },
    };
    if ($c->req->headers->content_type//'' =~ /multipart\/form-data/i) {
        for (@{ $c->req->uploads || [] }) {
            if ($_->{name} eq 'JSON') {
                $data = {
                    %$data,
                    %{ decode_json($_->asset->slurp) }
                };
            }
            else {
                $$data{$_->{name}} = $$data{$_->{name}}
                    ? ref $$data{$_->{name}} eq 'ARRAY'
                        ? [@{$$data{$_->{name}}}, $_]
                        : [$$data{$_->{name}}, $_]
                    : $_;
            }
        }
    }
    $c->data($data);

    # session ID
    $c->sid(1);

    $c->model($c->load_model($c->entity)) if !$c->modelless;

    # check access
    # sub _access_<action>
    # sub POST_access_<action>
    if (my $sub = $c->can($c->req->method . '_access_' . $c->action) || $c->can('_access_' . $c->action)) {
        return $c->rendered(403) if !$sub->($c);
    }

    # validate
    # sub _validate_<action>
    # sub POST_validate_<action>
    if (my $sub = $c->can($c->req->method . '_validate_' . $c->action) || $c->can('_validate_' . $c->action)) {
        my $errors = $sub->($c);
        return $c->req->is_xhr ? $c->render(json => $errors) : $c->render(text => 'error todo') if $errors;
    }

    # execute
    # sub POST_<action>
    # sub <action>
    if (my $sub = $c->can($c->req->method . '_' . $c->action) || $c->can($c->action)) {
        $c->stash(action => $c->action);
        my $resp = $sub->($c) || {};
        if ($$resp{data}) {
            $c->stash(D => $$resp{data});
            return $c->render;
        }
        elsif ($$resp{redirect}) {
            return $c->req->is_xhr ? $c->render(json => {redirect => $$resp{redirect}}) : $c->redirect_to($$resp{redirect});
        }
        elsif ($$resp{error}) {
            return $c->rendered($$resp{error});
        }
    }

    $c->reply->not_found;
}

# Default actions
sub item {
    { data => $_[0]->modelless ? {} : $_[0]->model->item({add_vocs => 1}) };
}

# item editing form
sub edit {
    $_[0]->item;
}

sub list {
    my ($c) = @_;
    if ($c->modelless) {
        return {data => {}};
    }
    else {
        my $list = $c->model->list($c->extract_data('list', {
            count       => 1,
            add_vocs    => 1,
            add_fields  => {
                -href   => sub {join '/', '', $c->entity, $_[0]->{id}}
            },
        }));
        return {data => $list};
    }
}

sub delete {
    my $c = shift;
    return {error => 404} if $c->modelless;
    $c->model->delete;
    return {redirect => '/' . $c->entity};
}

sub create {
    my $c = shift;
    return {error => 404} if $c->modelless;
    if (my $id = $c->model->create) {
        return {redirect => '/' . $c->entity . '/' . $id . ($c->after_create ? '/' . $c->after_create : '')};
    }
    else {
        return {error => 500};
    }
}

sub update {
    my $c = shift;
    return {error => 404} if $c->modelless;
    $c->model->update;
    return {redirect => '/' . $c->entity . '/' . $c->id . ($c->after_update ? '/' . $c->after_update : '')};
}

sub delete {
    my $c = shift;
    return {error => 404} if $c->modelless;
    $c->model->delete;
    return {redirect => '/' . $c->entity};
}

sub extract_data {
    my ($c, @args) = @_;
    my ($ns, $extend) = ('', {});
    for (@args) {
        $ns = $_, next if !ref $_;
        $extend = $_, next if ref $_;
    }
    $ns
    ? { (map {$_ => $c->data->{"$ns.$_"}} map /^$ns\.(.+)/, grep /^$ns\./, keys %{$c->data}), %$extend }
    : { %{$c->data}{ grep !/\./, keys %{$c->data} }, %$extend };
}

1;

