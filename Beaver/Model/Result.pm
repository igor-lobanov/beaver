package Beaver::Model::Result;
use Mojo::Base -base;
use Mojo::Collection;

has row     => sub {{}};
has rows    => sub {new Mojo::Collection};
has vocs    => sub {{}};
has count   => 0;
has portion => 10;
has start   => 0;

1;
