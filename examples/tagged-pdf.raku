use v6;
use PDF::API6;

use PDF::Content:ver<0.4.3+>; # required for tagged PDF
use PDF::Content::Color :ColorName;
use PDF::Content::Tag :ParagraphTags, :InlineElemTags, :IllustrationTags, :StructureTags;
use PDF::Content::Tag::Elem;
use PDF::Content::Tag::Root;

use PDF::Annot::Link;
use PDF::Page;
use PDF::XObject::Image;
use PDF::XObject::Form;

# -- Create logical (tagged) document root -- #
my PDF::Content::Tag::Root $tags .= new;
my PDF::API6 $pdf .= new: :$tags;
sub dest(|c) { :Dest($pdf.destination(|c)) }

my PDF::Content::Tag::Elem $doc = $tags.add-kid(Document);

my PDF::Page $page = $pdf.add-page();
$pdf.add-page();
my $header-font = $page.core-font: :family<Helvetica>, :weight<bold>;
my $body-font = $page.core-font: :family<Helvetica>;

$page.graphics: -> $gfx {

    # -- Add document header tag -- #
    $doc.add-kid(Header1).mark: $gfx, {
        .say('Header text',
             :font($header-font),
             :font-size(15),
             :position[50, 120]);
    }

    # -- Add tagged paragraph -- #
    $doc.add-kid(Paragraph).mark: $gfx, {
        .say('Some body text', :position[50, 100], :font($body-font), :font-size(12));
    }

    sub outer-rect(*@rects) {
        [
            @rects.map(*[0].round).min, @rects.map(*[1].round).min,
            @rects.map(*[2].round).max, @rects.map(*[3].round).max,
        ]
    }

    # -- Add tagged fgiure: image + caption -- #
    my PDF::XObject::Image $img .= open: "t/images/lightbulb.gif";

    my @rect;
    my PDF::Content::Tag::Elem $tag = $doc.add-kid(Figure);
    $tag.mark: $gfx, {
        @rect = outer-rect([
            $gfx.do($img, :position[50, 70]),
            $gfx.say("Eureka!", :tag<Caption>, :position[40, 60]),
            ]);
    }
    $tag.set-bbox($gfx, @rect);

    # -- Add annotation tagged as a link -- #
    my PDF::Annot::Link $link = $pdf.annotation(
        :page(1),
        :text("see page 2"),
        |dest(:page(2)),
        :color(Blue),
    );
    $doc.add-kid(Link).reference($gfx, $link);

    # -- Create a marked XObject form
    my PDF::XObject::Form $form = $page.xobject-form: :BBox[0, 0, 200, 50];
    $form.text: {
        my $font-size = 12;
        .text-position = [10, 38];
        .mark: Header1, { .say: "Marked XObject form header", :font($header-font), :$font-size};
        .mark: Paragraph, { .say: "Some sample marked text", :font($body-font), :$font-size};
    }

    # -- Insert the XObject into the page. --
    #    The `:marks` option adds marked XObject content to the
    #    structure tree (in this case 'H1' and 'P' elements)
    $doc.add-kid(Form).do: $gfx, $form, :marks, :position[150, 70];
}

# save the tagged PDF
$pdf.save-as: "examples/tagged.pdf";

=begin pod

=head1 NAME

tagged-pdf.raku - Tagged PDF example

=head1 SYNOPSIS

tagged-pdf.raku [output-pdf]

=head1 DESCRIPTION

A simple example demonstrating the writing of tagged content via
PDF::API6.

=head1 SEE ALSO

pdf-tag-dump.raku (PDF::Tags module)

=cut

=end pod
