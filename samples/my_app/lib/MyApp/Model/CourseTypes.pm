package MyApp::Model::CourseTypes;

use Mojo::Base 'Beaver::Model::Pg';
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
]};

1;

__DATA__

@@ MyApp::Model::CourseTypes

-- 1 up
CREATE TABLE course_types (
    id serial,
    fake bigint not null default -1,
    label text
);
-- 1 down
DROP TABLE course_types;

-- 2 up
ALTER TABLE course_types ADD CONSTRAINT course_types_pkey PRIMARY KEY(id);
-- 2 down
ALTER TABLE course_types DROP CONSTRAINT IF EXISTS course_types_pkey;
