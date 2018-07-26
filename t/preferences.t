use v6;
use Test;
use PDF::Grammar::Test :is-json-equiv;
plan 10;
use PDF::API6;
use PDF::Destination :Fit;
constant PageLabel = PDF::API6::PageLabel;

my PDF::API6 $pdf .= new;
my $page = $pdf.add-page;
$pdf.preferences: :hide-toolbar, :open{ :page(1), :fit(FitWindow) };
my $catalog = $pdf.Root;

is $catalog.PageLayout, 'SinglePage', 'PageLayout';
is $catalog.PageMode, 'UseNone', 'PageMode';
my $viewer-prefs = $catalog.ViewerPreferences;
is $viewer-prefs.HideToolbar, True, 'viewer HideToolbar';
is $viewer-prefs.NonFullScreenPageMode, 'UseNone', 'viewer non-full page-mode';

my $open-action = $catalog<OpenAction>;

isa-ok $open-action, Array, 'OpenAction';
is $open-action.elems, 2, 'OpenAction elems';
is-deeply $open-action[0], $page, 'OpenAction[0]';
is $open-action[1], 'Fit', 'OpenAction[1]';

my @page-labels = 0 => 'i',
                  4 =>  1,
                 32 =>  'A-1',
                 36 =>  'B-1',
                 40 =>  { :style(PageLabel::RomanUpper), :start(1), :prefix<B-> };

$pdf.page-labels = @page-labels;

is-json-equiv $pdf.page-labels, {0  => {:S<r>, :St(1)},
                                 4  => {:S<D>, :St(1)},
                                 32 => {:P<A->, :S<D>, :St(1)},
                                 36 => {:P<B->, :S<D>, :St(1)},
                                 40 => {:P<B->, :S<R>, :St(1)}}, '.page-labels accessor';

is-json-equiv $pdf.catalog.PageLabels, {
    :Nums[ 0, {:S<r>, :St(1)},
           4, {:S<D>, :St(1)},
          32, {:P<A->, :S<D>, :St(1)},
          36, {:P<B->, :S<D>, :St(1)},
          40, {:P<B->, :S<R>, :St(1)}
        ],
}, '.catalog.PageLabels';

$pdf.save-as: "tmp/preferences.pdf";

done-testing;

