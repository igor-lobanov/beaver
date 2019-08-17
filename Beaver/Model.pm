package Beaver::Model;
use Mojo::Base -base;
use Mojo::Collection;

has [qw(backend app entity definition c)];

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self->init(@_);
}

sub init { $_[0] }

sub item {
    my $m = shift;
    my ($id, $opts) = $m->_id_opts(@_);
    {
        entity  => $m->entity,
        id      => $id || $m->c->id || 0,
    };
}

sub list {
    my $m = shift;
    my $opts = $m->_opts(@_);
    wantarray ? [] : ([], 0);
}

sub fields {
    my ($m, $name) = @_;
    my $map = { map {$_->{name} => $_} @{ $m->definition } };
    return $name ? $$map{$name} : $m->definition || [];
}

sub field {
    $_[0]->fields($_[1]);
}

sub columns {
    my $m = shift;
    return new Mojo::Collection(map { $_->{name} } @{ $m->definition });
}

sub vocs {
    my $m = shift;
    my %vocs = map { $m->fields($_)->{vocabulary} => 1 } grep { $m->fields($_)->{vocabulary} } @{ $m->columns };
    return new Mojo::Collection(keys %vocs);
}

sub _id_opts {
    shift;
    my ($id, $opts) = (0, {});
    for (@_) {
        $id = $_, next if !ref $_;
        $opts = $_, next if ref $_;
    }
    return ($id, $opts);
}

sub _opts {
    shift;
    @_==1 ? $_[0] : { @_ };
}

1;

=pod

=encoding utf8

=head1 SYNOPSIS

    use Mojo::Base 'Beaver::Model';

    sub init {
        my $m = shift;
        # Model init code
        $m;
    }

    my $item = $m->item;

    my $items = $m->list;

    say $_ for $m->columns;

=head1 DESCRIPTION

L<Beaver::Model> is base class for Beaver low-level models.

=head1 ATTRIBUTES

=head2 backend

Reference to backend config section in config

=head2 app

Reference to application object. Models can use it to access application helpers for example.

=head2 entity

Name of entity which model represents.

=head2 definition

Data which describes model structure.

=head2 c

Reference to controller instance. Models can use it to access request data for example.

=head1 METHODS

=head2 init

Init code which is executed after creating model object instance. Redefined in child classes.

=head2 item

Prototype method for high-level method. B<item> must return entity item and other supplimentary item.

=head2 list

Prototype method for high-level method. B<list> must return structure with entity items collection and other supplimentary data.

=head2 fields

Returns single field descriptive structure or array of field descriptive structures.

=head2 field

Synonym for fields.

=head2 columns

Returns list of model fields.

=head2 vocs

Returns list of model fields which are vocabulary references.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<https://mojolicious.org>.

=cut

