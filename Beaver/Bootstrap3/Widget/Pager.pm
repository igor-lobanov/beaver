package Beaver::Bootstrap3::Widget::Pager;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    push @{$self->attrs->{class} ||= []}, (
        $self->oid,
    );

    $self->props->{length} ||= 7;
    $self->props->{length} = 3 if $self->props->{length}+0 < 3;
    $self->props->{count} ||= 0;
    $self->props->{portion} ||= 10;
    $self->props->{start} ||= 0;
    my ($length, $portion, $count, $start) = @{$self->props}{qw(length portion count start)};

    my $pages = int(($count-$start)/$portion) + (($count-$start) % $portion ? 1 : 0);
    $pages += int($start/$portion)+($start % $portion ? 1 : 0) if $start;
    my $page  = int($start/$portion) + ($start % $portion ? 1 : 0)+1;
    $page ||= 1;
    
    my @pages;
    if ($pages>$length) {
        @pages = ($page);
        for (1..$length) {
            push @pages, $page+$_ if $page+$_ <= $pages;
            unshift @pages, $page-$_ if $page-$_ >= 1;
            last if @pages >= $length;
        }
        if ($pages[0]>1) {
            unshift @pages, 1, -1;
        }
        if ($pages[-1]<$pages) {
            push @pages, -1, $pages;
        }
    }
    else {
        @pages = (1..$pages);
    }
    $self->props->{links} = \@pages;
    $self->props->{page} = $page;
    $self->props->{pages} = $pages;
    $self->props->{url} ||= sub {
        #my ($c, $wg, $page) = @_;
        $_[0]->build_url('list.start' => $_[1]->start($_[2]));
    };
    $self;
}

sub start {
    my ($self, $page) = @_;
    my $start = $self->props->{start}+($page-$self->props->{page})*$self->props->{portion};
    $start = $self->props->{count}-1 if $start>=$self->props->{count};
    $start = 0 if $start<0;
    $start;
}

1;

__DATA__

@@ widgets/pager.html.ep
<div class="container-fluid pt-20">
    <div class="row">
        <div class="col-md-12 text-right">
            <nav>
                <ul class="pagination">
%   if ($wg->props->{page} == 1) {
                    <li class="disabled"><span>&laquo;</span></li>
%   }
%   else {
                    <li><a href="<%= $wg->props->{url}->($c, $wg, $wg->props->{page}-1) %>">&laquo;</a></li>
%   }
%   for my $p (@{ $wg->props->{links} }) {
%       if ($p == -1) {
                    <li><span>...</span></li>
%       }
%       elsif ($p == $wg->props->{page}) {
                    <li class="active"><span><%= $p %></span></li>
%       }
%       else {
                    <li><a href="<%= $wg->props->{url}->($c, $wg, $p) %>"><%= $p %></a></li>
%       }
%   }
%   if ($wg->props->{page} == $wg->props->{pages}) {
                    <li class="disabled"><span>&raquo;</span></li>
%   }
%   else {
                    <li><a href="<%= $wg->props->{url}->($c, $wg, $wg->props->{page}+1) %>">&raquo;</a></li>
%   }
                </ul>
            </nav>
        </div>
    </div>
</div>
