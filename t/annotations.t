use v6;
use Test;
plan 14;
use PDF::API6;
use PDF::Destination :Fit;
use PDF::Annot::Link;
use PDF::Content::Color;
use PDF::Page;

my PDF::API6 $pdf .= new;

$pdf.add-page for 1 .. 2;

sub dest(|c) { :destination($pdf.destination(|c)) }
sub action(|c) { :action($pdf.action(|c)) }

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
                 |action(
                     :file<../t/pdf/OoPdfFormExample.pdf>,
                     :page(2), :fit(FitXYZoom), :top(400)
                 ),
                 :rect[ 377, 455, 455, 467 ],
                 :color[0, 0, 1],
             ); }, 'construct file annot';

ok  $page1.Annots[2] === $link, "remote link added";
use PDF::Action::GoToR;
my PDF::Action::GoToR $action = $link.action;
is $action.file, '../t/pdf/OoPdfFormExample.pdf', 'Goto annonation file';
is $action.destination.page, 2, 'Goto annonation page number';
is $action.destination.fit, FitXYZoom, 'Goto annonation fit';

use PDF::Annot::Text;
my PDF::Annot::Text $note;
my $text = "To be, or not to be: that is the question: Whether 'tis nobler in the mind to suffer the slings and arrows of outrageous fortune, or to take arms against a sea of troubles, and by opposing end them?";
lives-ok { $note = $pdf.annotation(
                 :page(1),
                 :$text,
                 :rect[ 377, 415, 455, 427 ],
                 :color[0, 0, 1],
             ); }, 'construct text note annot';

ok  $page1.Annots[3] === $note, "text annot added";
is $note.text, $text, "Text note annotation";
$pdf.save-as: "tmp/annotations.pdf";

done-testing;
