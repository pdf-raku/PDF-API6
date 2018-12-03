use v6;
use Test;
plan 5;
use PDF::API6;
use PDF::Annot::Link;
use PDF::Content::Color;
use PDF::Page;

my PDF::API6 $pdf .= new;

$pdf.add-page for 1 .. 5;

sub dest(|c) { :Dest($pdf.destination(|c)) }
sub action(|c) { :A($pdf.action(|c)) }

my PDF::Annot::Link $link;
lives-ok { $link = $pdf.annotation(
                 :page(1),
                 |dest(:page(2)),
                 :rect[ 377, 545, 455, 557 ],
                 :color[0, 0, 1],
             )}, 'construct link annot';

my PDF::Page $page1 = $pdf.page(1);

ok  $page1.Annots[0] === $link, "annot added to source page";
ok $link.destination.page == $pdf.page(2), "annot reference to destination page";

lives-ok { $link = $pdf.annotation(
                 :page(1),
                 |action(:uri<https://test.org>),
                 :rect[ 377, 515, 455, 527 ],
                 :color[0, 0, 1],
             ); }, 'construct uri annot';

is $link.action.URI, 'https://test.org', "annot reference to URI";

$pdf.save-as: "tmp/annotations.pdf";

done-testing;
