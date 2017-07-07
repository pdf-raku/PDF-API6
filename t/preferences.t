use v6;
use Test;
use PDF::API6;
plan 8;

my PDF::API6 $pdf .= new;
my $page = $pdf.add-page;
$pdf.preferences: :hide-toolbar, :first-page{ :$page, :fit };
my $catalog = $pdf.Root;

is $catalog<PageLayout>, 'SinglePage', 'PageLayout';
is $catalog<PageMode>, 'UseNone', 'PageMode';
my $viewer-prefs = $catalog<ViewerPreferences>;
is $viewer-prefs<HideToolbar>, True, 'viewer HideToolbar';
is $viewer-prefs<NonFullScreenPageMode>, 'UseNone', 'viewer non-full page-mode';

my $open-action = $catalog<OpenAction>;

isa-ok $open-action, Array, 'OpenAction';
is $open-action.elems, 2, 'OpenAction elems';
is-deeply $open-action[0], $page, 'OpenAction[0]';
is $open-action[1], 'Fit', 'OpenAction[1]';

done-testing;

