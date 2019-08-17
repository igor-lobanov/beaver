package MyApp::Controller::Courses;
use Mojo::Base 'Beaver::Controller';

use Data::Dumper;

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
        sort        => ['course_types.label', 'label'],
    }));
    return {data => $list};
}

1;
