package Beaver::Data;
use Mojo::Base -base;
use Mojo::Collection;

has data => sub {{}};

sub get {
    my ($self, $ns) = @_;
    $ns//'' eq '*'
        ? $self->data
        : $ns
            ? {%{$self->data}{grep /^$ns\./, keys %{$self->data} }}
            : {%{$self->data}{grep !/\./, keys %{$self->data} }};
}

sub add {
    my ($self, $data, $ns) = @_;
    my $prefix = $ns ? "$ns." : '';
    for (keys %$data) {
        my $key = $prefix . $_;
        if ($self->data->{$key}) {
            $self->data->{$key} = Mojo::Collection->new($self->data->{$key}) if ref $self->data->{$key} ne 'Mojo::Collection';
            push @{ $self->data->{$key} }, ref $data->{$_} eq 'ARRAY' ? @{ $data->{$_} } : $data->{$_};
        }
        else {
            $self->data->{$key} = ref $data->{$_} eq 'ARRAY' ? Mojo::Collection->new(@{ $data->{$_} }) : $data->{$_};
        }
    }
    $self;
}

# /gist/999/update?var1=value1&var2=2
# ?app.gist=gist&app.id=999&app.act=update&var1=value1&var2=2
# {
#   "app": {
#       "gist": "gist",
#       "id": 999,
#       "act": "update"
#   },
#   "data": {
#       "var1": "value1",
#       "var2": 2
#   }
# }

1;
