package Beaver::Schema;
use Mojo::Base -base;

has version => 1;

has fields => sub {{
    id      => {
        type    => 'integer',
        desc    => 'ID',
    },
    fake    => {
        type    => 'integer',
        desc    => 'Record flag',
    },
    label   => {
        type    => 'text',
        desc    => 'Label'
    },
}};

#sub up_1 {
#   return {
#       insert => [
#           {id => 3, label => 'Label 3'},
#           {id => 4, label => 'Label 4'},
#       ],
#       delete => [1, 2],
#   };
#}

1;
