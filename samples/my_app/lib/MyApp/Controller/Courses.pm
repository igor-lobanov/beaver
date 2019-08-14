package MyApp::Controller::Courses;
use Mojo::Base 'Beaver::Controller';

use Data::Dumper;

#sub list {
#    my $c = shift;
#    return {data => $c->model->list({}, {-href => sub {'/courses/' . $_[0]->{id}}})};
#}
sub list {
    my ($c) = @_;
    my $list = $c->model->list($c->extract_data('list', {
        count       => 1,
        add_vocs    => 1,
        join_vocs   => {
            id_course_type  => 'course_type_label',
        },
        add_fields  => {
            -href   => sub {join '/', '', $c->entity, $_[0]->{id}}
        },
        order       => [{'course_types.label'=>'desc'}, {id => 'asc'}],
    }));
    return {data => $list};
}

1;
