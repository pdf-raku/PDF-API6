use v6;
use Test;
plan 3;
use PDF::API6;
use PDF::Annot::Link;
use PDF::Content::Color;
use PDF::Page;

my PDF::API6 $pdf .= new;

$pdf.add-page for 1 .. 5;

sub dest(|c) { :Dest($pdf.destination(|c)) }

my PDF::Annot::Link $link;
lives-ok { $link = $pdf.annotation(
                 :rectangle[ 377, 145, 455, 157 ],
                 :color[0, 0, 1],
                 :page(1),
                 :link(dest(:page(2))),
             )}, 'construct link annot';

my PDF::Page $page1 = $pdf.page(1);

ok  $page1.Annots[0] === $link, "annot added to source page";
ok $link.destination.page == $pdf.page(2), "annot reference to destination page";

$pdf.save-as: "tmp/annotations.pdf";

done-testing;
