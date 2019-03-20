package Beaver::Bootstrap3::Widget::NavTabs;
use Mojo::Base 'Beaver::Bootstrap3::Widget';

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    delete @{$self->props||[]}{qw(vertical position)} if !$self->props->{pills} || $self->props->{justified};
    push @{$self->attrs->{class} ||= []}, (
        'nav',
        ($self->props->{pills} ? 'nav-pills' : 'nav-tabs'),
        ($self->props->{justified} ? ('nav-justified')
        : $self->props->{vertical} ? ('nav-stacked', 'col-md-3')
        : ()),
        $self->oid,
    );
    $self;
}

1;

__DATA__

@@ widgets/nav_tabs.html.ep
%   if (~~@{ $wg->props->{tabs} || [] }) {
%       my @blocks = (begin
<ul <%= $wg->pack_attrs %>>
%       for my $tab (@{ $wg->props->{tabs} }) {
    <li<%= $wg->pack_attrs({class => [('disabled') x!! ($tab->{disabled}), ('active') x!! ($tab->{active})]}, ' ') %>>
%           if ($tab->{href}) {
        <a href="<%=  $tab->{href} %>"><%= $tab->{label} %></a>
%           }
%           else {
        <a data-toggle="tab" href=".<%= $wg->oid . '-' . $tab->{suffix} %>"><%= $tab->{label} %></a>
%           }
    </li>
%       }
</ul>
%       end->());
%       push @blocks, begin
<div class="tab-content col-md-9">
<%= $wg->content %>
</div>
%       end->();
%       @blocks = reverse @blocks if $wg->props->{vertical} && $wg->props->{position} eq 'right';
%== join('', @blocks);
% js_onload begin
$('.<%= $wg->oid %> li[class="disabled"] a').on('click',function(){return false;});
% end
%   }
