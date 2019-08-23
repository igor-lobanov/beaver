package Beaver::Bootstrap3::Widget::Table;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

use Mojo::Collection;

has buttons => sub {new Mojo::Collection};

has link => sub {sub {undef}};

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        'table',
        $self->oid,
    );
    for (qw(striped bordered hover condensed)) {
        push @{ $self->attrs->{class} }, 'table-'.$_ if exists $self->props->{$_};
    }

    push @{ $self->buttons }, grep {
        ref $$_{-hide} ? $$_{-hide}->($self->c) : exists $$_{-hide} ? !$$_{-hide} : 1
    } grep {
        ref $$_{-show} ? $$_{-show}->($self->c) : exists $$_{-show} ? $$_{-show} : 1
    } grep {
        @{ $$_{-actions}||[] } ? any { $self->c->action eq $_ } @{ $$_{-actions}||[] } : 1
    }  @{ $self->props->{buttons}||[] };
    $self->link(sub { $self->props->{link}->(@_) }) if $self->props->{link};
    $self;
}

sub cells {
    my ($self, $row) = @_;
    ref $self->props->{cols} eq 'CODE' ? $self->props->{cols}->($row)
    : ref $row eq 'ARRAY' ? $row
    : ref $row eq 'HASH' ? [ map {$row->{$_}} @{ $self->props->{columns} || [] } ]
    : [];
}

sub row_attrs {
    my ($self, $row) = @_;
    my (%attrs, @class);
    if (ref $row eq 'HASH') {
        push @class, 'row-clickable' if $row->{-href} || $row->{-return};
        $attrs{'data-href'} = $row->{-href} if $row->{-href};
        map { /^-(\S+)$/; push @class, $1 } grep /^-(?:active|success|warning|danger|info)$/, keys %$row;
        $attrs{'data-return'} = '[]' if $row->{-return} && $self->props->{callback};
        @attrs{qw(data-toggle data-target)} = ('modal', $self->props->{popup}) if $self->props->{popup} && $row->{-href};
    }
    $attrs{class} = join(' ', @class) if ~~@class;
    return \%attrs;
}

sub cell_attrs {
    my ($self, $cell) = @_;
    my (%attrs, @classes);
    if (ref $cell eq 'HASH') {
    }
    return \%attrs;
}

1;

=encoding utf8

=head1 NAME

Beaver::Bootstrap3::Widget::Table - table widget

=head1 SYNOPSIS

  <%= widget table => {
    -striped    => 1,
    -bordered   => 1,
    -hover      => 1,
    -condensed  => 1,
    -responsive => 1,
    -header     => ['Name', 'Surname', 'Position', 'Salary'],
    -columns    => [qw(name surname position salary)],
    -popup      => ".modal_oid",
    -callback   => "parent.set_values",
    -data       => [{
        -warning    => 1,
        -href       => 'http://ivan-pushkin.com',
        id          => 5,
        name        => 'Ivan',
        surname     => 'Pushkin',
        position    => 'Backend engineer',
        salary      => 30000,
    }, {
        -success    => 1,
        -return     => ['id', 'name', 'salary'],
        id          => 10,
        name        => 'Ivan',
        surname     => 'Turgenev',
        position    => 'Frontend engineer',
        salary      => 90000,
    }],
    -buttons    => [
        'add',
        'export'
    ],
    -pager      => {
        count   => 1000,
        start   => 50,
        portion => 10,
    },
  } %>

=head1 DESCRIPTION

L<Beaver::Bootstrap3::Widget::Table> provides Bootstrap3 table componnent widget backend for L<Beaver::Plugin::Widgets>.

=head1 PROPERTIES

L<Beaver::Bootstrap3::Widget::Table> implements following properties.

=head2 striped

  <%= widget table => {
    -striped => 1',
  } %>

Adds zebra-striping to any table row within the <tbody>.

=head2 bordered

  <%= widget table => {
    -bordered => 1,
  } %>

Adds borders on all sides of the table and cells.

=head2 hover

  <%= widget table => {
    -hover => 1,
  } %>

Enables a hover state on table rows within a <tbody>.

=head2 condensed

  <%= widget table => {
    -condensed => 1,
  } %>

Makes tables more compact by cutting cell padding in half.

=head2 responsive

  <%= widget table => {
    -responsive => 1,
  } %>

Makes table responsive by adding horizontal scroll on small devices.

=head2 header

  <%= widget table => {
    -header     => ['Name', 'Surname', 'Position', 'Salary'],
  } %>

Displays column names in thead section.

=head2 columns

  <%= widget table => {
    -columns    => [qw(name surname position salary)],
    -data       => [{
        name        => 'Ivan',
        surname     => 'Pushkin',
        position    => 'Backend engineer',
        salary      => 30000,
        this_field  => 'will not be displayed',
    }],
  } %>

Defines order and hash key names of displayed data. It's required if data is array of hashes.

=head1 SEE ALSO

L<Mojolicious>, L<Beaver::Plugin::Widgets>.

=cut

__DATA__

@@ widgets/table.html.ep
% if ($wg->props->{responsive}) {
<div class="table-responsive">
% }
<table <%= $wg->pack_attrs %>>
% if ($wg->buttons->size || $wg->props->{label}) {
    <thead>
        <tr>
            <td colspan="<%= @{ $wg->props->{columns} } %>">
                <div class="container-fluid pt-20">
                    <div class="row">
                    <div class="col-md-4">
%   if ($wg->props->{label}) {
<h4><%= $wg->props->{label} %></h4>
%   }
                    </div>
                    <div class="col-md-8 text-right">
%   for my $btn ($wg->buttons->each) {
<%= widget button => ($btn) %>
%   }
                        </div>
                    </div>
                </div>
            </td>
        </tr>
    </thead>
% }
% if ($wg->props->{header}) {
    <thead>
%   for my $cell (@{ $wg->props->{header} }) {
        <th><%= $cell %></th>
%   }
    </thead>
% }
%   if (~~@{$wg->props->{data}}) {
    <tbody>
%       for my $row (@{ $wg->props->{data} }) {
        <tr<%== $wg->pack_attrs($wg->row_attrs($row), ' ') %>>
%           for my $cell (@{ $wg->cells($row) }) {
            <td<%== $wg->pack_attrs($wg->cell_attrs($cell), ' ') %>><%= ref $cell ? $cell->{value} : $cell %></td>
%           }
        </tr>
%       }
    </tbody>
%   }

%   if ($wg->props->{pager}) {
    <tfoot>
        <tr>
            <td colspan="<%= @{ $wg->props->{columns} } %>">
<%= widget pager => $wg->props->{pager} %>
            </td>
        </tr>
    </tfoot>
</table>
%   }
% if ($wg->props->{responsive}) {
</div>
% }
% if (!$wg->props->{popup}) {
%     js_onload begin
$("table.<%= $wg->oid %> tr.row-clickable[data-href]").on('click', function () {
    window.location = $(this).data('href');
});
%     end
% }
% if ($wg->props->{callback}) {
%     js_onload begin
$("table.<%= $wg->oid %> tr.row-clickable[data-return]").on('click', function () {
    <%= $wg->props->{callback} %>($(this).data('return'));
});
%     end
% }
