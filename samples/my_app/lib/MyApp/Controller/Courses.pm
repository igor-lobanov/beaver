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
    
    my @errors = map {{field => $_, message => 'Это поле необходимо'}} grep {$c->data->{$_} !~ /\S/} qw(label description);
    push @errors, map {{field => $_, message => 'Это поле необходимо'}} grep {$c->data->{$_} == 0} qw(id_course_type);
    push @errors, map {{field => $_, message => 'Неверный формат поля'}} grep {$c->data->{$_} !~ /^\d+$/} qw(id_course_type);

    return @errors ? [
        { alert => {message => "Форма содержит ошибки, данные не сохранены", title => "Есть ошибки", label_ok => "Понятно"} },
        @errors,
    ] : undef;
}

1;
