use v6;
use Test;
use PDF::Grammar::Test :is-json-equiv;
plan 9;
use PDF::API6;
constant PageLabel = PDF::API6::PageLabel;

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

$pdf.PageLabels = 0 => { :style(PageLabel::RomanUpper) },
                  4 => { :style(PageLabel::Decimal) },
                  32 => { :start(1), :prefix<A-> },
                  36 => { :start(1), :prefix<B-> },
                  40 => { :style(PageLabel::RomanUpper), :start(1), :P<B-> };

my @PageLabels = 0 , { :S(PageLabel::RomanUpper) },
                 4 , { :S(PageLabel::Decimal) },
                 32, { :St(1), :P<A-> },
                 36, { :St(1), :P<B-> },
                 40, { :S(PageLabel::RomanUpper), :St(1), :P<B-> };

is-json-equiv $pdf.PageLabels, @PageLabels, '.PageLabels';

done-testing;

