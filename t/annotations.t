use v6;
use Test;
plan 22;
use PDF::API6;
use PDF::Action::GoToR;
use PDF::Annot::FileAttachment;
use PDF::Annot::Link;
use PDF::Annot::Text;
use PDF::Border :BorderStyle;
use PDF::Content::Color :ColorName;
use PDF::Destination :Fit;
use PDF::Filespec;
use PDF::Page;
use PDF::XObject::Image;

my PDF::API6 $pdf .= new;

$pdf.add-page for 1 .. 2;
my PDF::Page $page1 = $pdf.page(1);
my PDF::Page $page2 = $pdf.page(2);

$page2.graphics: {
    .say: "Hello, I'm page2", :position[50, 600], :font-size(20);
}

sub dest(|c) { :destination($pdf.destination(|c)) }
sub action(|c) { :action($pdf.action(|c)) }

my $gfx = $pdf.page(1).gfx;

$gfx.Save;
$gfx.transform(:translate(5,10));

my PDF::Annot::Link $link;
$gfx.text: {
    .text-position = 377 -5 , 545 - 10;
    $link = $pdf.annotation(
        :text("See page 2"),
        :page(1),
        |dest(:name<foo>,:page(2)),
        :color(Blue),
    );
}

my Str $link-name = $link.destination;
is $link-name, 'foo'; # named destination

my PDF::Destination $dest = $pdf.catalog<Dests>{$link-name};
ok $dest.defined, "named destination added";
ok $dest.page === $page2, "dest page dereference";

ok $page1.Annots[0] === $link, "annot added to source page";
ok $page1.Annots[0].P === $pdf.page(1), "/P entry in annots";

my $image = PDF::XObject::Image.open: "t/images/lightbulb.gif";
my @image-region = $gfx.do($image, 350 - 5, 544 - 10);
my @rect = $gfx.base-coords: |@image-region;
lives-ok { $link = $pdf.annotation(
                 :page(1),
                 |dest(:page(2)),
                 :@rect,
                 :color(Blue),
             )}, 'construct link annot';

$gfx.Restore;

ok  $page1.Annots[1] === $link, "annot added to source page";
ok $link.destination.page == $page2, "annot reference to destination page";

$gfx.text: {
    .text-position = 377, 515;
    lives-ok { $link = $pdf.annotation(
                     :page(1),
                     :text("Test link"),
                     |action(:uri<https://test.org>),
                     :color(Orange),
                 ); }, 'construct uri annot';

    ok  $page1.Annots[2] === $link, "annot added to source page";
    is $link.action.URI, 'https://test.org', "annot reference to URI";

    .text-position = 377, 485;
    lives-ok { $link = $pdf.annotation(
                     :page(1),
                     :text("Example PDF Form"),
                     |action(
                         :file<../t/pdf/OoPdfFormExample.pdf>,
                         :page(2), :fit(FitXYZoom), :top(400)
                     ),
                     :color(Green),
                 ); }, 'construct file annot';

    ok  $page1.Annots[3] === $link, "remote link added";
    my PDF::Action::GoToR $action = $link.action;
    is $action.file, '../t/pdf/OoPdfFormExample.pdf', 'Goto annonation file';
    is $action.destination.page, 1, 'Goto annonation page index';
    is $action.destination.fit, FitXYZoom, 'Goto annonation fit';

    my PDF::Annot::Text $note;
    my $content = "To be, or not to be: that is the question: Whether 'tis nobler in the mind to suffer the slings and arrows of outrageous fortune, or to take arms against a sea of troubles, and by opposing end them?";

    lives-ok { $note = $pdf.annotation(
                     :page(1),
                     :$content,
                     :rect[ 377, 465, 455, 477 ],
                     :color[0, 0, 1],
                     :Open,
                 ); }, 'construct text note annot';

    ok  $page1.Annots[4] === $note, "text annot added";
    is $note.content, $content, "Text note annotation";

    my $border-style = {
        :width(1),  # 1 point width
        # 3 point dashes, alternating with 2-point gaps
        :style(BorderStyle::Dashed),
        :dash-pattern[3, 2],
    };

    .text-position = 377, 425;
    lives-ok { $link = $pdf.annotation(
                     :page(1),
                     |action(:uri<https://test2.org>),
                     :text("Styled Border"),
                     :color[.7, .8, .9],
                     :$border-style,
    ); }, 'construct styled uri annot';
    is $link.border-style.style, BorderStyle::Dashed, "setting of dashed border";

    my DateTime $ModDate .= new: :year(2001);
    my PDF::Filespec $attachment = $pdf.attachment("t/images/lightbulb.gif", :$ModDate);
    my PDF::Annot::FileAttachment $image-annot;
    lives-ok { $image-annot = $pdf.annotation(
                     :page(1),
                     :$attachment,
                     :text-label("Light Bulb"),
                     :content('An example attached image file'),
                     :icon-name<Paperclip>,
                     :rect[ 377, 395, 425, 412 ],
                 ); }, 'construct file attachment annot';

};

$pdf.id = $*PROGRAM-NAME.fmt('%-16.16s');
$pdf.save-as: "t/annotations.pdf", :!info;
done-testing;
