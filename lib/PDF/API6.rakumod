use PDF::Class:ver(v0.4.3+);

class PDF::API6:ver<0.2.6>
    is PDF::Class {

    use PDF::Action;
    use PDF::Action::GoTo;
    use PDF::Action::GoToR;
    use PDF::Action::URI;
    use PDF::Annot;
    use PDF::Catalog;
    use PDF::ColorSpace::DeviceN;
    use PDF::ColorSpace::Separation;
    use PDF::Destination :Fit, :DestRef, :DestDict, :&coerce-dest;
    use PDF::Info;
    use PDF::Filespec;
    use PDF::Function::Sampled;
    use PDF::Metadata::XML;
    use PDF::Page;

    use PDF::Class::Util :from-roman;
    use PDF::COS;
    use PDF::COS::Array;
    use PDF::COS::ByteString;
    use PDF::COS::Dict;
    use PDF::COS::Name;
    use PDF::API6::Preferences;

    subset PageRef where {$_ ~~ UInt|Str|PDF::Page|PDF::Destination|PDF::Action::GoTo};
    sub prefix:</>($name) { PDF::COS::Name.COERCE($name) };

    multi method page(PDF::Page $_) {
        $_;
    }
    multi method page(UInt:D $num) {
        self.Pages.page($num);
    }
    method destinations is rw {
        # Depending on the PDF named destinations may be a simple /Names hash in the catalog,
        # or a /Names /Dests name-tree
        given self<Root> {
            do with .<Names> {
                do with .<Dests> {
                    .name-tree;
                }
            } // .<Dests>
        }
    }
    multi method page(Str:D $name) {
        do with $.destinations {
            do with .{$name} -> PDF::Destination $_ {
                .[0];
            }
        } // PDF::Page;
    }
    multi method page(PDF::Destination:D $_) {
        my PDF::Page:D $ = .[0];
    }
    multi method page(DestDict:D $_) {
        self.page(.<D>);
    }
    multi method page(Any:U) {
        PDF::Page;
    }

    has PDF::API6::Preferences $.preferences;
    method preferences {
        $!preferences //= PDF::API6::Preferences.new: :$.catalog;
    }

    #| Make a miscellaneous named destination
    multi method destination(Str:D :$name! is copy, |c) {
        my PDF::Destination $dest = $.destination: |c;
        given $name {
            $_ = PDF::COS::Name.COERCE($_)
                unless $_ ~~ PDF::COS::Name|PDF::COS::ByteString;
        }
        $.destinations{$name} = $dest;
        $name;
    }

    #| Make a remote destination to a page (by number) in another PDF file
    multi method destination(
        Bool :$remote! where .so,
        UInt :$page! is copy,
        Fit :$fit = FitWindow,
        |c ) is default {
        # Remote destinations start at Page 0
        $page--;
        PDF::Destination.construct($fit, :$page, |c);
    }
    #| Make destination page (by object) within this PDF
    multi method destination(
        PageRef :page($page-ref)!,
        Fit :$fit = FitWindow,
        |c ) {
        my PDF::Page:D $page = self.page($page-ref);
        PDF::Destination.construct($fit, :$page, |c);
    }

    #| Make a remote action on a page in another PDF file
    multi method action(
        Str :$file!, UInt :$page!, |c
          --> PDF::Action::GoToR) {
        my $destination = $.destination(:$page, :remote, |c);
        PDF::Action::GoToR.COERCE: {
            :Type(/'Action'),
            :S(/'GoToR'),
            :$file,
            :$destination;
        };
    }

    #| Make a goto action to a page within this PDF
    multi method action( :$destination! ) {
        my $D = coerce-dest($destination, DestRef);
        PDF::Action::GoTo.COERCE: {
            :Type(/'Action'),
            :S(/'GoTo'),
            :$D
        };
    }

    sub uri-to-ascii($s) {
        $s.subst: rx/<- [\x0 .. \x7f]>/, { .Str.encode.list.fmt('%%%X', "") }, :g
    }

    #| Make a URI (link) action
    multi method action( Str :$uri! --> PDF::Action::URI) {
        my $URI = uri-to-ascii($uri);
        PDF::Action::URI.COERCE: {
            :Type(/'Action'),
            :S(/'URI'),
            :$URI
        };
    }
    multi method action( PDF::Action::URI :$uri!) { $uri; }

    method outlines is rw { self.catalog.Outlines //= {} };

    method is-encrypted { ? self.Encrypt }
    method info returns PDF::Info { self.Info //= {} }

    has PDF::Metadata::XML $.xmp-metadata is rw;
    method xmp-metadata is rw {
        $!xmp-metadata //= ($.catalog.Metadata //= {
            :Type(/<Metadata>),
            :Subtype(/<XML>),
        });

        $!xmp-metadata.decoded; # rw target
    }

    our Str enum PageLabel «
         :Decimal<D>
         :RomanUpper<R> :RomanLower<r>
         :AlphaUpper<A> :AlphaLower<a>
        »;

    #| Simple page numbering. e.g.: to-page-label(1);
    multi sub to-page-label(UInt $_) {
        %( S => /(Decimal.value), St => .Int )
    }
    #| Lowercase roman numerals, e.g. to-page-label('i');
    multi sub to-page-label(Str $_ where m/^<[ivxlc]>+$/) {
        %( S => /(RomanLower.value), St => from-roman($_) )
    }
    #| Uppercase roman numerals, e.g. to-page-label('I');
    multi sub to-page-label(Str $_ where m/^<[IVXLC]>+$/) {
        %( S => /(RomanUpper.value), St => from-roman($_) )
    }
    #| Numbering with a prefix, e.g. to-page-label('A-1');
    multi sub to-page-label(Str $ where m/^(.*?)(\d+)$/) {
        %( S => /(Decimal.value), P => ~$0, St => +$1 )
    }
    #| Explicit pre-built hash numbering schema
    multi sub to-page-label(Hash $_) { $_ }

    sub to-page-labels(Pair @labels) {
        my @page-labels;
        my UInt $seq;
        my UInt $n = 0;
        for @labels {
            my UInt $idx  = .key;
            my Any  $spec = .value;
            ++$n;
            with $seq {
                fail "out of sequence PageLabel index at offset $n: $idx"
                    if $idx <= $_;
            }
            $seq = $idx;
            @page-labels.push: $seq;
            @page-labels.push: to-page-label($spec);
        }
        @page-labels;
    }

    method page-labels is rw {
        Proxy.new(
            STORE => -> $, List $_ {
                my Pair @labels = .list;
                $.catalog.PageLabels = %( Nums => to-page-labels(@labels) );
            },
            FETCH => {
                .nums.Hash with $.catalog.PageLabels;
            },
        )
    }

    has PDF::Filespec %!attachments;
    #| Make a PDF attachment
    method attachment(Str $file-name,
                     IO::Path :$io = $file-name.IO,
                     blob8 :$decoded = $io.open(:bin).read,
                     :$ModDate = $io.modified.DateTime,
                     :$compress = True
                       --> PDF::Filespec) {
        my %dict = :Type(/'EmbeddedFile');
        %dict<Params> = %( :Size(.s), :$ModDate )
            with $io;
        my PDF::COS::Stream() $F = { :%dict, :$decoded };
        $F.compress if $compress;
        my PDF::Filespec() $filespec ={
            :Type(/<Filespec>),
            :$file-name,
            :embedded-file{ :$F },
        };

        %!attachments{$file-name} = $filespec;
    }

    method cb-finish {
        callsame;
        # final finishing hook for document. Called just prior to serializing
        if %!attachments {
            # new attachments to be added
            my $names = $.catalog.Names //= {};
            with $names.EmbeddedFiles {
                # construct a simple name tree /EmbeddedFiles entry in the Catalog. If
                # there's an existing tree, just flatten it. Potentially expensive for
                # a PDF that already has a large number of attachments.
                %!attachments ,= .name-tree.Hash;
            }
            my @Names = flat %!attachments.pairs.sort.map: { .key, .value };
            my @Limits = @Names[0], @Names.tail(2)[0];
            $names.EmbeddedFiles = { :@Names, :@Limits };
            %!attachments = ();
        }

    }

    method !annot(PageRef :page($page-ref)! is copy,
                  Str :$text,
                  *%dict is copy) { 

        my PDF::Page:D $page = $.page($page-ref);
        my $gfx = $page.gfx;
        my List $rect;

        %dict<Type> //= /'Annot';
        with $text {
            my $text-box = $gfx.text-box( :$text, :baseline<bottom>);
            my @text-region[4] = $gfx.print($text-box);
            @text-region[1] -= $text-box.TextRise;
            @text-region[3] -= $text-box.TextRise;
            %dict<rect> //= [ $gfx.base-coords: |@text-region ];
        }

        my PDF::Annot() $annot = %dict;

        # add a bidirectional link between the page and annotation
        $annot.page = $page;
        ($page.Annots //= []).push: $annot; 

        $annot;
    }

    #| Make a page annotation with a destination; e.g. link to another page
    multi method annotation(:$page!, DestRef :$destination!, *%props) {
        my $Subtype = /'Link';
        self!annot( :$Subtype, :$page, :$destination, |%props);
    }
    #| Alias :Dest to :destination
    multi method annotation(:Dest($destination)!, |c) {
        $.annotation(:$destination, |c);
    }

    #| Make a page annotation with an action; e.g. URL link
    multi method annotation(:$page!, PDF::Action :$action!, *%props) {
        my $Subtype = /'Link';
        self!annot( :$Subtype, :$page, :$action, |%props);
    }

    #| Make a file attachment annotation
    multi method annotation(:$page!, PDF::Filespec :$attachment!, *%props) {
        my $Subtype = /'FileAttachment';
        my $annot = self!annot( :$Subtype, :$page, :file-spec($attachment), |%props);
    }

    #| Make a page text (sticky note) annotation
    multi method annotation(:$page!, Str :$content!, *%props) {
        my $Subtype = /'Text';
        self!annot( :$Subtype, :$page, :$content, |%props);
    }

    subset DeviceColor of Pair where .key ~~ 'DeviceRGB'|'DeviceCMYK'|'DeviceGray';
    method color-separation(Str $name, DeviceColor $color --> PDF::ColorSpace::Separation) {
        my Numeric @Range;
        my List $v = $color.value;
        my Str $encoded;
        given $color.key {
            when 'DeviceRGB' {
                @Range = $v[0],1, $v[1],1, $v[2],1;
                $encoded = 'FF' x 3   ~  '00' x 3  ~  '>';
            }
            when 'DeviceCMYK' {
                @Range = 0,$v[0], 0,$v[1], 0,$v[2], 0,$v[3];
                $encoded = '00' x 4  ~  'FF' x 4  ~  '>';
            }
            when 'DeviceGray' {
                @Range = 0,$v[1];
                $encoded = 'FF00>';
            }
        }

        my %dict = :Domain[0,1], :@Range, :Size[2,], :BitsPerSample(8), :Filter( /<ASCIIHexDecode> );
        my PDF::Function::Sampled() $function = %( :%dict, :$encoded );
        PDF::ColorSpace::Separation.COERCE: [ /<Separation>, /$name, /($color.key), $function ];
    }

    method color-devicen(@colors --> PDF::ColorSpace::DeviceN) {
        my constant Sampled = 2;
        my $nc = +@colors;
        my num64 @samples[Sampled ** $nc;4];
        my @functions;

        for @colors {
            die "color is not a seperation"
                unless $_ ~~ PDF::ColorSpace::Separation;
            die "unsupported colorspace(s): {.[2]}"
                unless .[2] ~~ 'DeviceCMYK';
            my $function = .TintTransform.calculator;
            die "unsupported colorspace transform: {.TintTransform.perl}"
                unless $function.domain.elems == 1
                && $function.range.elems == 4;
            @functions.push: $function;
        }
        my @Domain = flat (0, 1) xx $nc;
        my @Range = flat (0, 1) xx 4;
        my @Size = 2 xx $nc;

        # create approximate compound function based on range maximum only.
        # Adapted from Perl 5's PDF::API2::Resource::ColorSpace::DeviceN
        my @xclr = @functions.map: {.calc([.domain».max])};

        for 0 ..^ $nc -> $xc {
            for 0 ..^ (Sampled ** $nc) -> $n {
                my \factor = ($n div (Sampled**$xc)) % Sampled;
                my @thiscolor = @xclr[$xc].map: { ($_ * factor)/(Sampled-1) };
                for 0..3 -> $s {
                    @samples[$n; $s] += @thiscolor[$s];
                }
            }
        }

        my buf8 $decoded .= new: @samples.flat.map: {(min($_,1.0) * 255).round};

        my %dict = :@Domain, :@Range, :@Size, :BitsPerSample(8), :Filter( /<ASCIIHexDecode> );
        my @names = @colors.map: *.Name;
        my %Colorants = @names Z=> @colors;

        my PDF::Function::Sampled() $function = %( :%dict, :$decoded );
        PDF::ColorSpace::DeviceN.COERCE: [ /<DeviceN>, @names, /<DeviceCMYK>, $function, { :%Colorants } ];
    }
}
