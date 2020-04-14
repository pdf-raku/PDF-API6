#!/usr/bin/env raku
use v6;

use PDF::API6;
    enum ( :Keys<T>, :Labels<TU> );

#| list all fields and current values
multi sub MAIN(
    Str $infile,            #| input PDF
    Bool :list($)! where .so,
    Bool :$labels,          #| display labels, rather than keys
    Str  :$password = '',   #| password for the PDF/FDF, if encrypted
    UInt :$page,            #| selected page
    ) {
    my PDF::API6 $pdf .= open($infile, :$password);
    my @fields = ($page ?? $pdf.page($page) !! $pdf).fields;

    if @fields {
        my $n = 0;
        for @fields {
            my $key = .TU if $labels;
            $key //= .T // '???';
            # value is commonly a text-string or name, but can
            # also be dictionary object (e.g. PDF::Signature)
            my $value = (.V // '').perl;
            say "{++$n}. $key: $value";
        }
    }
    else {
	warn "this {$pdf.type} has no form fields";
    }
}

#| list all fields and current values
multi sub MAIN(
    Str $infile,            #| input PDF
    Bool :reformat($)! where .so,
    Str  :$save-as,
    Str  :$password = '',   #| password for the PDF/FDF, if encrypted
    ) {
    my PDF::API6 $pdf .= open($infile, :$password);
    with $pdf.Root.AcroForm {
        .NeedAppearances = True;
        .<AP>:delete for .fields;
    }
    else {
	warn "this {$pdf.type} has no form fields";
    }

    with $save-as {
        $pdf.save-as( $_ );
    }
    else {
        $pdf.update;
    }
}

my subset PosInt of Int where * > 0;
#| update PDF, setting specified fields from name-value pairs
multi sub MAIN(
    Str $infile,
    Bool :fill($)! where .so,
    UInt :$first! is copy,
    Str  :$save-as,
    Str  :$password = '',
    UInt :$page,            #| selected page
    *@field-values) {

    my PDF::API6 $pdf .= open($infile, :$password);
    die "$infile has no fields defined"
	unless $pdf.Root.AcroForm;

    die "please provide a list of values --list to display fields"
	unless @field-values;

    my @fields = ($page ?? $pdf.page($page) !! $pdf).fields;
    my $n = +@fields;
    $first--;
    die  "too many field values"
        if $first + @field-values > $n;

    for @field-values -> $v {
        my $fld = @fields[$first++];
	$fld.V = $v;
    }

    with $save-as {
        $pdf.save-as( $_ );
    }
    else {
        $pdf.update;
    }
}

multi sub MAIN(
    Str $infile,
    Bool :fill($)! where .so,
    Str  :$save-as,
    Bool :$labels,          #| display labels, rather than keys
    Str  :$password = '',
    UInt :$page,            #| selected page
    *@field-list) {

    my PDF::API6 $pdf .= open($infile, :$password);
    die "$infile has no fields defined"
	unless $pdf.Root.AcroForm;

    die "please provide field-value pairs or --list to display fields"
	unless @field-list;

    die "last field not paired with a value: {@field-list.tail}"
	unless +@field-list %% 2;

    my Str $key = $labels ?? Labels !! Keys;
    my %fields = ($page ?? $pdf.page($page) !! $pdf).fields-hash: :$key;

    for @field-list -> $key, $val {
	if %fields{$key}:exists {
	    %fields{$key}.V = $val;
	}
	else {
	    warn "no such field: $key. Use --list to display fields";
	}
    }

    with $save-as {
        $pdf.save-as( $_ );
    }
    else {
        $pdf.update;
    }
}

=begin pod

=head1 NAME

pdf-fields.raku - Manipulate PDF/FDF fields

=head1 SYNOPSIS

 pdf-fields.raku --list infile.[pdf|fdf]
 pdf-fields.raku --reformat [--save-as=outfile.pdf] infile.pdf
 pdf-fields.raku --fill [--save-as=outfile.pdf] infile.pdf [options] [field value ...]
 pdf-fields.raku --fill [--save-as=outfile.pdf] infile.pdf --first=i [value value ...]

 Options
   --list               list fields and current values
       --page=n             - select nth page
       --labels             - display field labels rathere than keys
   --fill               fill fields from command-line values
       --page=n             - select nth page
       --first=n            - fill nth field onwards in tab order
       --save-as=file.pdf   - save to a new file
   --reformat           reset field formatting
       --save-as=file.pdf   - save to a new file

 General Options:
   --password           provide user/owner password for an encrypted PDF

=head1 DESCRIPTION

List, reformat or fill PDF form fields.

=head1 SEE ALSO

`fillpdffields.pl` from the Perl CAM::PDF CPAN module

=end pod
