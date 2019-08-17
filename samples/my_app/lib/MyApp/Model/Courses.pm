package MyApp::Model::Courses;

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
        label       => 'Название',
        type        => 'text',
        sortable    => 1,
    },
    {
        name        => 'description',
        label       => 'Описание',
        type        => 'text',
        sortable    => 1,
    },
    {
        name        => 'dt_create',
        label       => 'Дата создания',
        type        => 'date',
        sortable    => 1,
    },
    {
        name        => 'id_course_type',
        label       => 'Тип курса',
        type        => 'int',
        sortable    => 1,
        vocabulary  => 'course_types',
    },
]};

1;

__DATA__

@@ MyApp::Model::Courses

-- 1 up
CREATE TABLE courses (
    id serial,
    fake bigint not null default -1,
    label text
);
-- 1 down
DROP TABLE courses;

-- 2 up
ALTER TABLE courses ADD CONSTRAINT courses_pkey PRIMARY KEY(id);
-- 2 down
ALTER TABLE courses DROP CONSTRAINT IF EXISTS courses_pkey;

-- 3 up
ALTER TABLE courses ADD COLUMN dt_create date DEFAULT now();
-- 3 down
ALTER TABLE courses DROP COLUMN dt_create;

-- 4 up
ALTER TABLE courses ADD CONSTRAINT courses_label_check CHECK (length(label) <= 255);
-- 4 down
ALTER TABLE courses DROP CONSTRAINT courses_label_check;

-- 5 up
ALTER TABLE courses ADD COLUMN description text;
-- 5 down
ALTER TABLE courses DROP COLUMN description;

-- 6 up
ALTER TABLE courses ADD CONSTRAINT courses_description_check CHECK (length(description) <= 1024);
-- 6 down
ALTER TABLE courses DROP CONSTRAINT courses_description_check;

-- 7 up
ALTER TABLE courses ADD COLUMN id_course_type int DEFAULT 0;
-- 7 down
ALTER TABLE courses DROP COLUMN id_course_type;

