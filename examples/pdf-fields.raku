#!/usr/bin/env raku
use v6;

use PDF::API6;

#| list all fields and current values
multi sub MAIN(
    Str $infile,            #| input PDF
    Bool :$list!,
    Bool :$labels,          #| display labels, rather than keys
    Str  :$password = '',   #| password for the PDF/FDF, if encrypted
    ) {
    my PDF::API6 $pdf .= open($infile, :$password);
    enum ( :Keys<T>, :Labels<TU> );
    my Str $key = $labels ?? Labels !! Keys;
    my %fields-hash = $pdf.fields-hash: :$key;

    if %fields-hash {
        for %fields-hash.pairs.sort {
            my $key = .key;
            # value is commonly a text-string or name, but can
            # also be dictionary object (e.g. PDF::Signature)
            my $value = (.value.V // '').perl;
            say "$key: $value";
        }
    }
    else {
	warn "this {$pdf.type} has no form fields";
    }
}

#| update PDF, setting specified fields from imported FDF or name-value pairs
multi sub MAIN(
    Str $infile,
    Bool :$fill!,
    Str  :$save-as,
    Bool :$trigger-clear,
    Str  :$password = '',
    *@field-list) {

    my PDF::API6 $pdf .= open($infile, :$password);
    die "$infile has no fields defined"
	unless $pdf.Root.AcroForm;

    die "please provide field-value pairs or --list to display fields"
	unless @field-list;

    die "last field not paired with a value: {@field-list.tail}"
	unless +@field-list %% 2;

    my %fields = $pdf.Root.AcroForm.fields-hash;

    for @field-list -> $key, $val {
	if %fields{$key}:exists {
	    # CAM::PDF is working harder here and resizing/styling the field to accomodate the field value
	    # todo: port CAM::PDF::fillFormFields sub. fill-form method in PDF::Struct::Field?
	    %fields{$key}.V = $val;
	    %fields{$key}<AA>:delete
		if $trigger-clear;
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
 pdf-fields.raku --fill [--save-as outfile.pdf] [options] infile.pdf [field value ...]

 Options
   --list               list fields and current values
       --labels             display field labels rathere than keys
   --fill               fill fields from an fdf, or command-line values
       --save-as=file.pdf   save to a new file
       --trigger-clear      remove all of the form triggers after replacing values

 General Options:
   --password           provide user/owner password for an encrypted PDF

=head1 DESCRIPTION

List, fill or export PDF form fields.

=head1 SEE ALSO

`fillpdffields.pl` from the Perl CAM::PDF CPAN module

=end pod
