package Beaver::Model::Pg::Common;

use Mojo::Base 'Beaver::Model::Pg';
use Beaver::Model::Result;

sub init {
    my $m = shift;
    $m->SUPER::init(@_);
    my $mg = $m->pg->migrations->name(ref $m)->from_data(ref $m);
    $mg->migrate;
    $m;
}

=pod

=head1 Beaver::Model::Pg::Common

=encoding utf8

=head1 SYNOPSIS

    # define model class
    package MyApp::Model::Goods;
    use Mojo::Base 'Beaver::Model::Pg::Common';
    
    has backend => 'Pg1';

    has definition => sub {[
        {
            name        => 'id',
            label       => 'ID',
            type        => 'int',
            sortable    => 1,
        },
        {
            name        => 'fake',
            label       => 'Fake',
            type        => 'bigint',
            sortable    => 0,
        },
        {
            name        => 'label',
            label       => 'Title',
            type        => 'text',
            sortable    => 1,
        },
        {
            name        => 'description',
            label       => 'Description',
            type        => 'text',
            sortable    => 0,
        },
    ]};

    1;

    __DATA__

    @@ MyApp::Model::Goods

    -- 1 up
    CREATE TABLE goods (
        id serial,
        fake bigint not null default -1,
        label text,
        description text,
    );
    -- 1 down
    DROP TABLE goods;

    # Load model
    my $m = $c->load_model('goods');

    # Get row by id
    $m->item->row;
    
    # Get set of rows
    my $result = $m->list({count => 1});
    # count of rows in table
    say $result->count;
    # count of rows in result set
    $result->rows->count;

=head1 DESCRIPTION

L<Beaver::Model::Pg::Common> is base class for Beaver models based on Pg database.

=head1 ATTRIBUTES

Class inherits attributes from L<Beaver::Model::Pg>

=head1 METHODS

Class inherits methods from L<Beaver::Model::Pg>

=cut

1;
