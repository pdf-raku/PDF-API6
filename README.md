PDF::API6 - A Perl 6 PDF Toolchain
===

- [NAME](#name)
- [DESCRIPTION](#description)
- [DIFFERENCES BETWEEN PDF::API2 AND PDF::API6](#differences-between-pdfapi2-and-pdfapi6)
   - [PDF::API6](#pdfapi6)
   - [TODO](#todo)
- [SYNOPSIS](#synopsis)
- [SECTION I: Low Level Methods](#section-i-low-level-methods)
   - [Input/Output](#inputoutput)
       - [new](#new)
       - [open](#open)
       - [update](#update)
       - [save-as](#save-as)
       - [encrypt](#encrypt)
       - [is-encrypted](#is-encrypted)
   - [Serialization Methods](#serialization-methods)
       - [Str, Blob](#str-blob)
       - [ast](#ast)
- [SECTION II: Graphics Methods (inherited from PDF::Lite)](#section-ii-graphics-methods-inherited-from-pdflite)
   - [Pages](#pages)
       - [page](#page)
       - [add-page](#add-page)
   - [Text](#text)
       - [font](#font)
       - [text](#text)
       - [print](#print)
       - [say](#say)
   - [Graphics](#graphics)
       - [graphics](#graphics)
       - [transform](#transform)
       - [paint](#paint)
   - [Images](#images)
       - [load-image](#load-image)
       - [do](#do)
   - [XObject Forms](#xobject-forms)
   - [Patterns](#patterns)
       - [tiling-pattern](#tiling-pattern)
       - [use-pattern](#use-pattern)
   - [Page Methods](#page-methods)
       - [to-xobject](#to-xobject)
       - [images](#images)
       - [Low Level Graphics](#low-level-graphics)
       - [Colors](#colors)
       - [Text](#text)
       - [Painting](#painting)
       - [Clipping](#clipping)
       - [Graphics State](#graphics-state)
- [SECTION III: PDF::API6 Specific Methods](#section-iii-pdfapi6-specific-methods)
       - [info](#info)
       - [preferences](#preferences)
       - [Page Layout Options:](#page-layout-options)
       - [Viewer Options:](#viewer-options)
       - [Initial Page Options:](#initial-page-options)
       - [Examples](#examples)
       - [version](#version)
       - [PageLabels](#pagelabels)
       - [xmp-metadata](#xmp-metadata)
- [APPENDIX: Graphics Operators and Variables](#appendix-graphics-operators-and-variables)
   - [Appendix I: Graphics](#appendix-i-graphics)
       - [Graphic Operators](#graphic-operators)
       - [Graphics State](#graphics-state)
       - [Text Operators](#text-operators)
       - [Path Construction](#path-construction)
       - [Path Painting Operators](#path-painting-operators)
       - [Path Clipping](#path-clipping)
       - [Graphics Variables](#graphics-variables)

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

## TODO

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

# SECTION I: Low Level Methods

Methods inherited from PDF

## Input/Output

### new

Creates a new PDF object.

    my PDF::API6 $pdf .= new();
    #...
    print $pdf.Str;
    $fh.write: $pdf.Blob;

    $pdf = PDF::API6.new();
    #...
    $pdf.save-as('our/new.pdf');


### open

Opens an existing PDF or JSON file.

    my PDF::API6 $pdf .= open('our/old.pdf');
    #...
    $pdf.save-as('our/new.pdf');

    # open from a stream
    my PDF::API6 $pdf2 .= open($pdf.Blob);


Open an encrypted document:

    PDF::API6.open( "enc.pdf", :password<shh1> );


### update

Performs a fast incremental save of a previously opened document.

    PDF::API6 $pdf .= open('our/to/be/updated.pdf');
    #...
    $pdf.update();

### save-as

Save the document to a file

    PDF::API6 $pdf .= new;
    #...
    $pdf.save-as: 'our/new.pdf';

A PDF file can also be saved as, and opened from an intermediate JSON representation

    PDF::API6 $pdf .= new;
    #...
    $pdf.save-as: 'our/pdf-dump.json';
    # ...
    $pdf.open: 'our/pdf-dump.json';

### encrypt

Encrypt a PDF:

    $pdf.encrypt( :owner-pass<ssh1>, :user-pass<abc>, :aes );

### is-encrypted

Check if document is encrypted

    if $pdf.is-encrypted

## Serialization Methods

### Str, Blob

Return a binary representation of a PDF as a latin-01 string, or binary Blob

    Str $latin-1 = $pdf.Str;  Blob $bytes = $pdf.Blob;

### ast

Return an AST tree representation of a PDF.

    Pair $ast = $pdf.ast


# SECTION II: Graphics Methods (inherited from PDF::Lite)

## Pages

### page

### add-page


## Text

### font

### text

### print

### say


## Graphics

### graphics

### transform

### paint


## Images

### load-image

### do

## XObject Forms


## Patterns

### tiling-pattern

### use-pattern


## Page Methods

### to-xobject

### images

### Low Level Graphics

### Colors

#### StrokeColor, StrokeAlpha

#### FillColor, FillAlpha

### Text

### Painting

### Clipping

### Graphics State

#### CTM (Transform Matrix)
#### Save
#### Restore

...



# SECTION III: PDF::API6 Specific Methods

### info

    %info := $pdf.info;

Gets/sets the info for the document

    $pdf.info<Title> = 'Some Publication';

### preferences

Controls viewing preferences for the PDF.

#### `:page-mode<fullscreen>`

Full-screen mode, with no menu bar, window controls, or any other window visible.

#### `:page-mode<thumbs>`

Thumbnail images visible.

#### `:page-mode<outlines>`

Document outline visible.


### Page Layout Options:

#### `:page-layout<singlepage>`

Display one page at a time.

#### `:page-layout<one-column>`

Display the pages in one column.

#### `:page-layout<two-column-left>`

Display the pages in two columns, with oddnumbered pages on the left.

#### `:page-layout<two-column-right>`

Display the pages in two columns, with oddnumbered pages on the right.

#### `:direction<r2l>`, `:direction<l2r>`

The predominant reading order for text:

- `l2r` Left to right

- `r2l` Right to left (vertical writing systems, such as Chinese, Japanese, and Korean)


#### `:page-scaling<none>`

Disables application page-scaling.


### Viewer Options:

#### `:hide-toolbar`

Specifying whether to hide tool bars.

#### `:hide-menubar`

Specifying whether to hide menu bars.

#### `:hide-windowui`

Specifying whether to hide user interface elements.

#### `:fit-window`

Specifying whether to resize the document's window to the size of the displayed page.

#### `:center-window`

Specifying whether to position the document's window in the center of the screen.

#### `:display-title`

Specifying whether the window's title bar should display the
document title taken from the Title entry of the document information
dictionary.

#### `:after-fullscreen<thumbs>`

Thumbnail images visible after Full-screen mode.

#### `:after-fullscreen<outlines>`

Document outline visible after Full-screen mode.

#### `:print-scaling<none>`

Set the default print setting for page scaling to none.

#### `:duplex<simplex>`

Print single-sided by default.

#### `:duplex<flip-short-edge>`

Print duplex by default and flip on the short edge of the sheet.

#### `:duplex<flip-long-edge>`

Print duplex by default and flip on the long edge of the sheet.

### Initial Page Options:

#### `:firstpage{ :$page, *%options }`

Specifying the page (either a page number or a page object) to be
displayed, plus one of the following options:

##### `:fit`

Display the page designated by page, with its contents magnified just
enough to fit the entire page within the window both horizontally and
vertically. If the required horizontal and vertical magnification
factors are different, use the smaller of the two, centering the page
within the window in the other dimension.

##### `:fith($top)`

Display the page designated by page, with the vertical coordinate top
positioned at the top edge of the window and the contents of the page
magnified just enough to fit the entire width of the page within the
window.

##### `:fitv($left)`

Display the page designated by page, with the horizontal coordinate
left positioned at the left edge of the window and the contents of the
page magnified just enough to fit the entire height of the page within
the window.

##### `:fitr[ $left, $bottom, $right, $top ]`

Display the page designated by page, with its contents magnified just
enough to fit the rectangle specified by the coordinates left, bottom,
right, and top entirely within the window both horizontally and
vertically. If the required horizontal and vertical magnification
factors are different, use the smaller of the two, centering the
rectangle within the window in the other dimension.

##### `:fitb`

Display the page designated by page, with its contents magnified just
enough to fit its bounding box entirely within the window both
horizontally and vertically. If the required horizontal and vertical
magnification factors are different, use the smaller of the two,
centering the bounding box within the window in the other dimension.

##### `:fitbh($top)`

Display the page designated by page, with the vertical coordinate top
positioned at the top edge of the window and the contents of the page
magnified just enough to fit the entire width of its bounding box
within the window.

##### `:fitbv($left)`

Display the page designated by page, with the horizontal coordinate
left positioned at the left edge of the window and the contents of the
page magnified just enough to fit the entire height of its bounding
box within the window.

##### `:xyz[ $left, $top, $zoom ]`

Display the page designated by page, with the coordinates (left, top)
positioned at the top-left corner of the window and the contents of
the page magnified by the factor zoom. A zero (0) value for any of the
parameters left, top, or zoom specifies that the current value of that
parameter is to be retained unchanged.

### Examples

    $pdf.preferences: :hide-toolbar, :first-page{ :page(2), :fit };

[see also examples/preferences.p6](examples/preferences.p6)

### version

    $pdf.version = v1.5;

Get or set the PDF Version

### PageLabels

Get or sets page numbers to identify each page number, for display or printing:

PageLabels is an array of ascending ascending intenger indexes. Each is followed
by a page entry hash. For example

    constant PageLabel = PDF::API6::PageLabel;
    $pdf.PageLabels = 0  => { :style(PageLabel::RomanUpper) },
                      4  => { :style(PageLabel::Decimal) },
                      32 => { :start(1), :prefix<A-> },
                      36 => { :start(1), :prefix<B-> },
                      40 => { :Style(PageLabel::RomanUpper), :start(1), :prefix<B-> };

### xmp-metadata

    Str $xml = $pdf.xmp-metadata;

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

...

# APPENDIX: Graphics Operators and Variables

## Appendix I: Graphics

### Graphic Operators

#### Color Operators

Method | Code | Description
--- | --- | ---
SetStrokeColorSpace(name) | CS | Set the current space to use for stroking operations. This can be a standard name, such as 'DeviceGray', 'DeviceRGB', 'DeviceCMYK', or a name declared in the parent's Resource<ColorSpace> dictionary.
SetStrokeColorSpace(name) | cs | Same but for nonstroking operations.
SetStrokeColor(c1, ..., cn) | SC | Set the colours to use for stroking operations in a device. The number of operands required and their interpretation depends on the current stroking colour space: DeviceGray, CalGray, and Indexed colour spaces, have one operand. DeviceRGB, CalRGB, and Lab colour spaces, three operands. DeviceCMYK has four operands.
SetStrokeColorN(c1, ..., cn [,pattern-name]) | SCN | Same as SetStrokeColor but also supports Pattern, Separation, DeviceN, ICCBased colour spaces and patterns.
SetFillColor(c1, ..., cn) | sc | Same as SetStrokeColor, but for non-stroking operations.
SetFillColorN(c1, ..., cn [,pattern-name]) | scn | Same as SetStrokeColorN, but for non-stroking operations.
SetStrokeGray(level) | G | Set the stroking colour space to DeviceGray and set the gray level to use for stroking operations, between 0.0 (black) and 1.0 (white).
SetFillGray(level) | g | Same as G but used for nonstroking operations.
SetStrokeRGB(r, g, b) | RG | Set the stroking colour space to DeviceRGB and set the colour to use for stroking operations. Each operand shall be a number between 0.0 (minimum intensity) and 1.0 (maximum intensity).
SetFillRGB(r, g, b) | rg | Same as RG but used for nonstroking operations.
SetFillCMYK(c, m, y, k) | K | Set the stroking colour space to DeviceCMYK and set the colour to use for stroking operations. Each operand shall be a number between 0.0 (zero concentration) and 1.0 (maximum concentration). The behaviour of this operator is affected by the OverprintMode graphics state.
SetStrokeRGB(c, m, y, k) | k | Same as K but used for nonstroking operations.

### Graphics State

Method | Code | Description
--- | --- | ---
Save() | q | Save the current graphics state on the graphics state stack
Restore() | Q | Restore the graphics state by removing the most recently saved state from the stack and making it the current state.
ConcatMatrix(a, b, c, d, e, f) | cm | Modify the current transformation matrix (CTM) by concatenating the specified matrix
SetLineWidth(width) | w | Set the line width in the graphics state
SetLineCap(cap-style) | J | Set the line cap style in the graphics state (see LineCap enum)
SetLineJoin(join-style) | j | Set the line join style in the graphics state (see LineJoin enum)
SetMiterLimit(ratio) | M | Set the miter limit in the graphics state
SetDashPattern(dashArray, dashPhase) | d | Set the line dash pattern in the graphics state
SetRenderingIntent(intent) | ri | Set the colour rendering intent in the graphics state: AbsoluteColorimetric, RelativeColormetric, Saturation, or Perceptual
SetFlatness(flat) | i | Set the flatness tolerance in the graphics state. flatness is a number in the range 0 to 100; 0 specifies the output device’s default flatness tolerance.
SetGraphics(dictName) | gs | Set the specified parameters in the graphics state. dictName is the name of a graphics state parameter dictionary in the ExtGState resource subdictionary

### Text Operators

Method | Code | Description
--- | --- | ---
BeginText() | BT | Begin a text object, initializing $.TextMatrix, to the identity matrix. Text objects shall not be nested.
EndText() | ET | End a text object, discarding the text matrix.
TextMove(tx, ty) | Td | Move to the start of the next line, offset from the start of the current line by (tx, ty ); where tx and ty are expressed in unscaled text space units.
TextMoveSet(tx, ty) | TD | Move to the start of the next line, offset from the start of the current line by (tx, ty ). Set $.TextLeading to ty.
SetTextMatrix(a, b, c, d, e, f) | Tm | Set $.TextMatrix
TextNextLine| T* | Move to the start of the next line
ShowText(string) | Tj | Show a text string
MoveShowText(string) | ' | Move to the next line and show a text string.
MoveSetShowText(aw, ac, string) | " | Move to the next line and show a text string, after setting $.WordSpacing to  aw and $.CharSpacing to ac
ShowSpacetext(array) |  TJ | Show one or more text strings, allowing individual glyph positioning. Each element of array shall be either a string or a number. If the element is a string, show it. If it is a number, adjust the text position by that amount

### Path Construction

Method | Code | Description
--- | --- | ---
MoveTo(x, y) | m | Begin a new subpath by moving the current point to coordinates (x, y), omitting any connecting line segment. If the previous path construction operator in the current path was also m, the new m overrides it.
LineTo(x, y) | l | Append a straight line segment from the current point to the point (x, y). The new current point shall be (x, y).
CurveTo(x1, y1, x2, y2, x3, y3) | c | Append a cubic Bézier curve to the current path. The curve shall extend from the current point to the point (x 3 , y 3 ), using (x1 , y1 ) and (x2 , y2 ) as the Bézier control points. The new current point shall be (x3 , y3 ).
ClosePath | h | Close the current subpath by appending a straight line segment from the current point to the starting point of the subpath.
Rectangle(x, y, width, Height) | re | Append a rectangle to the current path as a complete subpath, with lower-left corner (x, y) and dimensions `width` and `height`.

### Path Painting Operators

Method | Code | Description
--- | --- | ---
Stroke() | S | Stroke the path.
CloseStroke() | s | Close and stroke the path. Same as: $.Close; $.Stroke
Fill() | f | Fill the path, using the nonzero winding number rule to determine the region. Any open subpaths are implicitly closed before being filled.
EOFill() | f* | Fill the path, using the even-odd rule to determine the region to fill
FillStroke() | B | Fill and then stroke the path, using the nonzero winding number rule to determine the region to fill.
EOFillStroke() | B* | Fill and then stroke the path, using the even-odd rule to determine the region to fill.
CloseFillStroke() | b | Close, fill, and then stroke the path, using the nonzero winding number rule to determine the region to fill.
CloseEOFillStroke() | b* | Close, fill, and then stroke the path, using the even-odd rule to determine the region to fill.
EndPath() | n | End the path object without filling or stroking it. This operator shall be a path-painting no-op, used primarily for the side effect of changing the current clipping path.

### Path Clipping

Method | Code | Description
--- | --- | ---
Clip() | W | Modify the current clipping path by intersecting it with the current path, using the nonzero winding number rule to determine which regions lie inside the clipping path.
EOClip() | W* | Modify the current clipping path by intersecting it with the current path, using the even-odd rule to determine which regions lie inside the clipping path.

### Graphics Variables

#### Text Variables

Accessor | Code | Description | Default | Example Setters
-------- | ------ | ----------- | ------- | -------
TextMatrix | Tm | Text transformation matrix | [1,0,0,1,0,0] | .TextMatrix = :scale(1.5);
CharSpacing | Tc | Character spacing | 0.0 | .CharSpacing = 1.0
WordSpacing | Tw | Word extract spacing | 0.0 | .WordSpacing = 2.5
HorizScaling | Th | Horizontal scaling (percent) | 100 | .HorizScaling = 150
TextLeading | Tl | New line Leading | 0.0 | .TextLeading = 12; 
Font | [Tf, Tfs] | Text font and size | | .font = [ .core-font( :family\<Helvetica> ), 12 ]
TextRender | Tmode | Text rendering mode | 0 | .TextRender = TextMode::Outline::Text
TextRise | Trise | Text rise | 0.0 | .TextRise = 3

#### General Graphics - Common

Accessor | Code | Description | Default | Example Setters
-------- | ------ | ----------- | ------- | -------
CTM |  | The current transformation matrix | [1,0,0,1,0,0] | use PDF::Content::Matrix :scale;<br>.ConcatMatrix: :scale(1.5); 
DashPattern | D |  A description of the dash pattern to be used when paths are stroked | solid | .DashPattern = [[3, 5], 6];
FillAlpha | ca | The constant shape or constant opacity value to be used for other painting operations | 1.0 | .FillAlpha = 0.25
FillColor| | current fill colorspace and color | :DeviceGray[0.0] | .FillColor = :DeviceCMYK[.7,.2,.2,.1]
LineCap  |  LC | A code specifying the shape of the endpoints for any open path that is stroked | 0 (butt) | .LineCap = LineCaps::RoundCaps;
LineJoin | LJ | A code specifying the shape of joints between connected segments of a stroked path | 0 (miter) | .LineJoin = LineJoin::RoundJoin
LineWidth | w | Stroke line-width | 1.0 | .LineWidth = 2.5
StrokeAlpha | CA | The constant shape or constant opacity value to be used when paths are stroked | 1.0 | .StrokeAlpha = 0.5;
StrokeColor| | current stroke colorspace and color | :DeviceGray[0.0] | .StrokeColor = :DeviceRGB[.7,.2,.2]

#### General Graphics - Advanced

Accessor | Code | Description | Default
-------- | ------ | ----------- | -------
AlphaSource | AIS | A flag specifying whether the current soft mask and alpha constant parameters shall be interpreted as shape values or opacity values. This flag also governs the interpretation of the SMask entry | false |
BlackGeneration | BG2 | A function that calculates the level of the black colour component to use when converting RGB colours to CMYK
BlendMode | BM | The current blend mode to be used in the transparent imaging model |
Flatness | FT | The precision with which curves shall be rendered on the output device. The value of this parameter gives the maximum error tolerance, measured in output device pixels; smaller numbers give smoother curves at the expense of more computation | 1.0 
Halftone dictionary | HT |  A halftone screen for gray and colour rendering
MiterLimit | ML | number The maximum length of mitered line joins for stroked paths |
OverPrintMode | OPM | A flag specifying whether painting in one set of colorants should cause the corresponding areas of other colorants to be erased or left unchanged | false
OverPrintPaint | OP | A code specifying whether a colour component value of 0 in a DeviceCMYK colour space should erase that component (0) or leave it unchanged (1) when overprinting | 0
OverPrintStroke | OP | " | 0
RenderingIntent | RI | The rendering intent to be used when converting CIE-based colours to device colours | RelativeColorimetric
SmoothnessTolerance | ST | The precision with which colour gradients are to be rendered on the output device. The value of this parameter (0 to 1.0) gives the maximum error tolerance, expressed as a fraction of the range of each colour component; smaller numbers give smoother colour transitions at the expense of more computation and memory use.
SoftMask | SMask | A soft-mask dictionary specifying the mask shape or mask opacity values to be used in the transparent imaging model, or the name: None | None
StrokeAdjust | SA | A flag specifying whether to compensate for possible rasterization effects when stroking a path with a line | false
TransferFunction | TR2 |  A function that adjusts device gray or colour component levels to compensate for nonlinear response in a particular output device
UndercolorRemovalFunction | UCR2 | A function that calculates the reduction in the levels of the cyan, magenta, and yellow colour components to compensate for the amount of black added by black generation
