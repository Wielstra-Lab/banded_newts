#!/usr/bin/perl

use strict;
use warnings;

my $inFile = shift();
my $outFile = shift();
open(my $inFH, "<", $inFile) or die "Couldn't open $inFile for reading: $!\n";
open(my $outFH, ">", $outFile) or die "Couldn't open $outFile for writing: $!\n";

my %resultsHash;

while (my $line = <$inFH>) {
    chomp($line);

    # Print out the header lines
    if ($line =~ /\#/) {
        print $outFH $line . "\n";
        next;
    }

    my @fields = split(/\t/, $line);

    # This adds the lines to an array for each RAD tag ('chromosome' in VCF-speak). We'll choose a random line later after we populate the hash
    push(@{$resultsHash{$fields[0]}}, $line);
}


foreach my $chrom (sort {$a <=> $b} keys %resultsHash) {
    print $outFH ${$resultsHash{$chrom}}[rand @{$resultsHash{$chrom}}] . "\n";
}
