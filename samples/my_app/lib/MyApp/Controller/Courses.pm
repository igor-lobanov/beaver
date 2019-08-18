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

sub POST_validate_update {
    my $c = shift;
    
    my @errors;
    push @errors, {field => 'label', message => 'Это поле необходимо'} if !$c->data->{label};

    return @errors ? [
        { alert => {message => "Форма содержит ошибки, данные не сохранены", title => "Есть ошибки", label_ok => "Понятно"} },
        @errors,
    ] : undef;
}

1;
