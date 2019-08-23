package Beaver::Response;
use Mojo::Base -base;
use Mojo::Collection;

has [qw(redirect c)];
has errors => sub {new Mojo::Collection};

sub add_error {
    my $r = shift;
    push @{$r->errors},
        @_==2 ? { field => $_[0], message => $_[1] } :
        @_==1 ? { alert => { message => $_[0] } } :
        ();
}

1;

=pod

=encoding utf8

=head1 SYNOPSIS

    use Beaver::Response;

    my $resp = new Beaver::Response;

    $resp->add_errors(label => 'Can not be empty');
    $resp->add_errors('Form invalid');

    $resp->redirect('/');

=head1 DESCRIPTION

L<Beaver::Response> is class for managing controller responses.

=head1 ATTRIBUTES

=head2 redirect

=head2 errors

=head1 METHODS

=head2 add_error

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<https://mojolicious.org>.

=cut

