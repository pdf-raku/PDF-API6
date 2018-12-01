use v6;
use PDF::Class:ver(v0.2.8+);

class PDF::API6:ver<0.1.1>
    is PDF::Class {

    use PDF::COS;
    use PDF::Catalog;
    use PDF::Info;
    use PDF::Metadata::XML;
    use PDF::Page;
    use PDF::Destination :Fit;
    use PDF::Class::Util :from-roman;
    use PDF::API6::Preferences;

    sub to-name(Str $name) { PDF::COS.coerce: :$name }

    has PDF::API6::Preferences $.preferences;
    method preferences {
        $!preferences //= do {
            my $catalog = self.catalog;
            PDF::API6::Preferences.new: :$catalog;
        }
    }

    multi method destination(UInt :page($page-num)!, |c ) {
        # resolve a page number to a page object
        my $page = self.page($page-num);
        $.destination(:$page, |c);
    }
    multi method destination(
        PDF::Page :$page!,
        Fit :$fit = FitWindow,
        |c ) is default {
        PDF::Destination.construct($fit, :$page, |c);
    }

    method outlines is rw { self.catalog.Outlines //= {} };

    method is-encrypted { ? self.Encrypt }
    method info returns PDF::Info { self.Info //= {} }
    method xmp-metadata is rw {
        my PDF::Metadata::XML $metadata = $.catalog.Metadata //= {
            :Type( to-name(<Metadata>) ),
            :Subtype( to-name(<XML>) ),
        };

        $metadata.decoded; # rw target
    }

    our Str enum PageLabel «
         :Decimal<D>
         :RomanUpper<R> :RomanLower<r>
         :AlphaUpper<A> :AlphaLower<a>
        »;

    multi sub to-page-label(UInt $_) {
        %( S => to-name(Decimal.value), St => .Int )
    }
    multi sub to-page-label(Str $_ where /^<[ivxlc]>+$/) {
        %( S => to-name(RomanLower.value), St => from-roman($_) )
    }
    multi sub to-page-label(Str $_ where /^<[IVXLC]>+$/) {
        %( S => to-name(RomanUpper.value), St => from-roman($_) )
    }
    multi sub to-page-label(Str $ where /^(.*?)(\d+)$/) {
        %( S => to-name(Decimal.value), P => ~$0, St => +$1 )
    }
    multi sub to-page-label(Hash $l) {
        my % = $l.keys.sort.map: {
            when 'numbering-style' |'S'  { S  => to-name($l{$_}.Str) }
            when 'style' |'S'  {warn ":style is deprecated in page labels. Please use :numbering-style";
                                S  => to-name($l{$_}.Str) }
            when 'start' |'St' { St => $l{$_}.Int }
            when 'prefix'|'P'  { P  => $l{$_}.Str }
            default { warn "ignoring PageLabel field: $_" }
        }
    }

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
            STORE => sub ($, List $_) {
                my Pair @labels = .list;
                $.catalog.PageLabels = %( Nums => to-page-labels(@labels) );
            },
            FETCH => sub ($) {
                .nums.Hash with $.catalog.PageLabels;
            },
        )
    }

    method fields {
        .fields with $.catalog.AcroForm;
    }

    method fields-hash {
        .fields-hash with $.catalog.AcroForm;
    }

    use PDF::Function::Sampled;
    use PDF::ColorSpace::Separation;
    subset DeviceColor of Pair where .key ~~ 'DeviceRGB'|'DeviceCMYK'|'DeviceGray';
    method color-separation(Str $name, DeviceColor $color --> PDF::ColorSpace::Separation) {
        my @Range;
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

        my %dict = :Domain[0,1], :@Range, :Size[2,], :BitsPerSample(8), :Filter( :name<ASCIIHexDecode> );
        my PDF::Function::Sampled $function .= new: :%dict, :$encoded;
        PDF::COS.coerce: [ :name<Separation>, :$name, :name($color.key), $function ];
    }

    method color-devicen(@colors) {
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

        # create approximate compound function based on ranges only.
        # Adapted from Perl 5's PDF::API2::Resource::ColorSpace::DeviceN
        my @xclr = @functions.map: {.calc([.domain>>.max])};

        for 0 ..^ $nc -> $xc {
            for 0 ..^ (Sampled ** $nc) -> $n {
                my \factor = ($n div (Sampled**$xc)) % Sampled;
                my @thiscolor = @xclr[$xc].map: { ($_ * factor)/(Sampled-1) };
                for 0..3 -> $s {
                    @samples[$n;$s] += @thiscolor[$s];
                }
            }
        }

        my buf8 $decoded .= new: @samples.flat.map: {(min($_,1.0) * 255).round};

        my %dict = :@Domain, :@Range, :@Size, :BitsPerSample(8), :Filter( :name<ASCIIHexDecode> );
        my @names = @colors.map: *.Name;
        my %Colorants = @names Z=> @colors;

        my PDF::Function::Sampled $function .= new: :%dict, :$decoded;
        PDF::COS.coerce: [ :name<DeviceN>, @names, :name<DeviceCMYK>, $function, { :%Colorants } ];
    }
}
