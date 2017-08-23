#!/usr/bin/env perl6
use v6;
use PDF::API6;
use PDF::Reader;

sub MAIN(Str $infile,              #| input PDF
	 Str :$password = '',      #| password for the input PDF, if encrypted
	 Str :$save-as = $infile,  #| output PDF
	 Bool :$count,             #| show the number of revision
    ) {

    my $input = $infile eq q{-}
        ?? $*IN
	!! $infile;

    my PDF::Reader $reader = PDF::API6.open( $input, :$password).reader;

    my UInt $revs = + $reader.xrefs;

    if $count {
	say $revs;
    }
    elsif $revs < 1 {
	die "Error: this does not seem to be a PDF document\n";
    }
    elsif $revs == 1 {
	die "Error: there is only one revision in this PDF document.  It cannot be reverted.\n";
    }
    else {
        my UInt $prev = $reader.xrefs[*-2];
	my Str $body = $reader.input.substr(0, $prev);
	my Str $xref = $reader.input.substr($prev);
        $xref ~~ s/<after \n'%%EOF'> .* $/\n/;

	my $fh = $save-as eq q{-}
	   ?? $*OUT
	   !! $save-as.IO.open( :w, :enc<latin-1> );

	$fh.print: $body;
	$fh.print: $xref;
	$fh.close;
    }
}


=begin pod

=head1 NAME

pdf-revert.p6 - Remove the last edits to a PDF document

=head1 SYNOPSIS

 pdf-revert.p6 [options] --save-as=outfile.pdf infile.pdf

 Options:
   -c --count          just print the number of revisions and exits

=head1 DESCRIPTION

PDF documents have the interesting feature that edits can be applied
just to the end of the file without altering the original content.
This makes it possible to recover previous versions of a document.
This is only possible if the editor writes out an 'unoptimized'
version of the PDF.

This program removes the last layer of edits from the PDF document.  If
there is just one revision, we emit a message and abort.

The C<--count> option just prints the number of generations the document
has endured and applies no changes.

=head1 SEE ALSO

CAM::PDF (Perl 5)
PDF (Perl 6)

=head1 AUTHOR

See L<CAM::PDF>

=end pod