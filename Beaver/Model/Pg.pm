package Beaver::Model::Pg;

use Mojo::Base 'Beaver::Model';
has [qw(backend sql)];

sub init {
    my $self = shift;
    $self;
}

1;
