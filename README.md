# NAME

PDF::API6 - Facilitates the creation and modification of PDF files

A Perl 6 PDF tool-chain; reminiscent of Perl 5's PDF::API2.

# SYNOPSIS

    use PDF::API6;

    # Create a blank PDF file
    $pdf = PDF::API6.new();

    # Open an existing PDF file
    $pdf = PDF::API6.open('some.pdf');

    # Add a blank page
    $page = $pdf.add-page();

    # Retrieve an existing page
    $page = $pdf.page($page_number);

    # Set the page size
    $page.mediabox('Letter');

    # Add a built-in font to the PDF
    $font = $pdf.corefont('Helvetica-Bold');

    # Add an external TTF font to the PDF
    #NYI $font = $pdf.ttfont('/path/to/font.ttf');

    # Add some text to the page
    $page.text: -> $text {
        $text.font($font, 20);
        $text.translate(200, 700);
        $text.print('Hello World!');
    }

    # Save the PDF
    $pdf.save-as('/path/to/new.pdf');

## GENERIC METHODS

### new
Creates a new PDF object.

#### Example

    my PDF::API6 $pdf .= new();
    ...
    print $pdf.Str;
    $fh.write: $pdf.Blob;

    $pdf = PDF::API6.new();
    ...
    $pdf.save-as('our/new.pdf');


### open

Opens an existing PDF file.

#### Example

    my PDF::API6 $pdf .= open('our/old.pdf');
    ...
    $pdf.save-as('our/new.pdf');

    $pdf = PDF::API6.open('our/to/be/updated.pdf');
    ...
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

### Example

    my PDF::API6 $pdf .= new;
    my $page = $pdf.add-page;
    $pdf.preferences: :hidetoolbar, :first-page{ :$page, :fitv(10) };
