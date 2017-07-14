# NAME

PDF::API6 - Facilitates the creation and modification of PDF files

# DESCRIPTION

A Perl 6 PDF module; reminiscent of Perl 5's PDF::API2.

This module is a work in progress in replicating, or mapping the functionality of Perl 5's PDF::API2 toolchain.

# DIFFERENCES BETWEEN PDF::API2 AND PDF::API6

## PDF::API6

- Has a Graphics State engine. This is based on the graphics operators and variables as described PDF 32000 chapter 8 "Graphics and the operators".

- Supports the creation and manipulation of XObject Forms and Patterns.

- Implements an Object Graph model for data access. A PDF file is modelled as an object tree of Dictionaries (Hashes) and Arrays that contain simpler
values such as Integers, Reals and Strings.

- Has fast incremental updates. Small changes to a large PDF can often be quite efficiently.

# TODO

Some PDF::API2 features that are not yet available in PDF::API6

- Fonts. PDF::API6 currently only handles the standard 14 core fonts. No yet supported:

    - `psfont' - for loading postscript fonts
    - `ttfont` - for loading true type fonts
    - `synfont` - for creating synthetic fonts
    - `bdfont` - for creating BDF fonts
    - `unifont` - for Unicode fonts

- Images. PDF::API6 supports PNG, JPEG and GIF images

    - currently not supported are: TIFF, PNM and GIF images.

- ColorSpaces. PDF::API6 supports Gray, RGB and CMYK colors. Not supported yet:

    - Separation Colorspaces
    - DeviceN Colorspaces

- Annotations

- Outlines

- Destinations

- Page Labels (and page trees)

# SYNOPSIS

    use PDF::API6;

    # Create a blank PDF file
    my PDF::API6 $pdf .= new();

    # Open an existing PDF file
    $pdf = PDF::API6.open('some.pdf');

    # Add a blank page
    my $page = $pdf.add-page();

    # Retrieve an existing page
    $page = $pdf.page($page_number);

    # Set the page size
    use PDF::Content::Page :PageSizes;
    $page.MediaBox = Letter;

    # Add a built-in font to the PDF
    $font = $pdf.core-font('Helvetica-Bold');

    # Add an external TTF font to the PDF
    #NYI $font = $pdf.ttfont('/path/to/font.ttf');

    # Add some text to the page
    $page.text: {
        .font = $font, 20;
        .TextMove = 200, 700;
        .say('Hello World!');
    }

    # Save the PDF
    $pdf.save-as('/path/to/new.pdf');

## GENERIC METHODS

### new
Creates a new PDF object.

#### Example

    my PDF::API6 $pdf .= new();
    #...
    print $pdf.Str;
    $fh.write: $pdf.Blob;

    $pdf = PDF::API6.new();
    #...
    $pdf.save-as('our/new.pdf');


### open

Opens an existing PDF file.

#### Example

    my PDF::API6 $pdf .= open('our/old.pdf');
    #...
    $pdf.save-as('our/new.pdf');

    $pdf = PDF::API6.open('our/to/be/updated.pdf');
    #...
    $pdf.update();

    # open from a stream
    my PDF::API6 $pdf2 .= open($pdf.Blob);

### preferences

Controls viewing preferences for the PDF.

##### `:page-mode<fullscreen>`

Full-screen mode, with no menu bar, window controls, or any other window visible.

##### `:page-mode<thumbs>`

Thumbnail images visible.

##### `:page-mode<outlines>`

Document outline visible.


#### Page Layout Options:

##### `:page-layout<singlepage>`

Display one page at a time.

##### `:page-layout<one-column>`

Display the pages in one column.

##### `:page-layout<two-column-left>`

Display the pages in two columns, with oddnumbered pages on the left.

##### `:page-layout<two-column-right>`

Display the pages in two columns, with oddnumbered pages on the right.

##### `:direction<r2l>`, `:direction<l2r>`

The predominant reading order for text:

- `l2r` Left to right

- `r2l` Right to left (vertical writing systems, such as Chinese, Japanese, and Korean)


##### `:page-scaling<none>`

Disables application page-scaling.


#### Viewer Options:

##### `:hide-toolbar`

Specifying whether to hide tool bars.

##### `:hide-menubar`

Specifying whether to hide menu bars.

##### `:hide-windowui`

Specifying whether to hide user interface elements.

##### `:fit-window`

Specifying whether to resize the document's window to the size of the displayed page.

##### `:center-window`

Specifying whether to position the document's window in the center of the screen.

##### `:display-title`

Specifying whether the window's title bar should display the
document title taken from the Title entry of the document information
dictionary.

##### `:after-fullscreen<thumbs>`

Thumbnail images visible after Full-screen mode.

##### `:after-fullscreen<outlines>`

Document outline visible after Full-screen mode.

##### `:print-scaling<none>`

Set the default print setting for page scaling to none.

##### `:duplex<simplex>`

Print single-sided by default.

##### `:duplex<flip-short-edge>`

Print duplex by default and flip on the short edge of the sheet.

##### `:duplex<flip-long-edge>`

Print duplex by default and flip on the long edge of the sheet.

#### Initial Page Options:

##### `:firstpage{ :$page, *%options }`

Specifying the page (either a page number or a page object) to be
displayed, plus one of the following options:

###### `:fit`

Display the page designated by page, with its contents magnified just
enough to fit the entire page within the window both horizontally and
vertically. If the required horizontal and vertical magnification
factors are different, use the smaller of the two, centering the page
within the window in the other dimension.

###### `:fith($top)`

Display the page designated by page, with the vertical coordinate top
positioned at the top edge of the window and the contents of the page
magnified just enough to fit the entire width of the page within the
window.

###### `:fitv($left)`

Display the page designated by page, with the horizontal coordinate
left positioned at the left edge of the window and the contents of the
page magnified just enough to fit the entire height of the page within
the window.

###### `:fitr[ $left, $bottom, $right, $top ]`

Display the page designated by page, with its contents magnified just
enough to fit the rectangle specified by the coordinates left, bottom,
right, and top entirely within the window both horizontally and
vertically. If the required horizontal and vertical magnification
factors are different, use the smaller of the two, centering the
rectangle within the window in the other dimension.

###### `:fitb`

Display the page designated by page, with its contents magnified just
enough to fit its bounding box entirely within the window both
horizontally and vertically. If the required horizontal and vertical
magnification factors are different, use the smaller of the two,
centering the bounding box within the window in the other dimension.

###### `:fitbh($top)`

Display the page designated by page, with the vertical coordinate top
positioned at the top edge of the window and the contents of the page
magnified just enough to fit the entire width of its bounding box
within the window.

###### `:fitbv($left)`

Display the page designated by page, with the horizontal coordinate
left positioned at the left edge of the window and the contents of the
page magnified just enough to fit the entire height of its bounding
box within the window.

###### `:xyz[ $left, $top, $zoom ]`

Display the page designated by page, with the coordinates (left, top)
positioned at the top-left corner of the window and the contents of
the page magnified by the factor zoom. A zero (0) value for any of the
parameters left, top, or zoom specifies that the current value of that
parameter is to be retained unchanged.

#### Examples

    $pdf.preferences: :hide-toolbar, :first-page{ :page(2), :fit };

[see also examples/preferences.p6](examples/preferences.p6)

### $pdf.version = v1.5;

Get or set the PDF Version

## Encryption

Open an encrypted document:

    PDF::API6.open( "enc.pdf", :password<shh1> );

Encrypt a PDF:

    $pdf.encrypt( :owner-pass<ssh1>, :user-pass<abc>, :aes );

Check if document is encrypted

    if $pdf.is-encrypted

## %info = $pdf.info;

Gets/sets the info for the document

    $pdf.info<Title> = 'Some Publication';

## Str $xml = $pdf.xmp-metadata;

Gets/sets the XMP XML data stream.

Example:

    my $xml = q:to<EOT>;
        <?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?>
        <?adobe-xap-filters esc="CRLF"?>
        <x:xmpmeta
          xmlns:x='adobe:ns:meta/'
          x:xmptk='XMP toolkit 2.9.1-14, framework 1.6'>
            <rdf:RDF
              xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
              xmlns:iX='http://ns.adobe.com/iX/1.0/'>
                <rdf:Description
                  rdf:about='uuid:b8659d3a-369e-11d9-b951-000393c97fd8'
                  xmlns:pdf='http://ns.adobe.com/pdf/1.3/'
                  pdf:Producer='Acrobat Distiller 6.0.1 for Macintosh'></rdf:Description>
                </rdf:Description>
            </rdf:RDF>
        </x:xmpmeta>
        <?xpacket end='w'?>
        EOT

    $pdf.xmp-metadata = $xml

## Pages (PDF::API2::Page)

## XObjects and Patterns

## Extended Graphics State

...

