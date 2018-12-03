use v6;
use Test;
plan 13;
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

ok  $page1.Annots[1] === $link, "annot added to source page";
is $link.action.URI, 'https://test.org', "annot reference to URI";

lives-ok { $link = $pdf.annotation(
                 :page(1),
                 |action(:file</sbin/poweroff>),
                 :rect[ 377, 485, 455, 497 ],
                 :color[0, 0, 1],
             ); }, 'construct file annot';

is $link.action.file, '/sbin/poweroff', "annot reference to file";

ok  $page1.Annots[2] === $link, "file added to source page";

lives-ok { $link = $pdf.annotation(
                 :page(1),
                 |action(
                     :file<../t/pdf/OoPdfFormExample.pdf>,
                     :page(2),
                 ),
                 :rect[ 377, 455, 455, 467 ],
                 :color[0, 0, 1],
             ); }, 'construct file annot';

ok  $page1.Annots[3] === $link, "remote link added";
use PDF::Action::GoToR;
my PDF::Action::GoToR $action = $link.action;
is $action.file, '../t/pdf/OoPdfFormExample.pdf', 'Goto annonation file';
is $action.destination.page, 2, 'Goto annonation page number';

$pdf.save-as: "tmp/annotations.pdf";

done-testing;
