#!/bin/bash

module load SAMtools 
module load R/4.2.2-foss-2022b

MyIn=$1
MyCov="${MyIn}_Coverage"
MyOut="${MyIn}_PeakCoverage"
MyNotes="${MyIn}_PeakNotes"

echo $MyIn
echo $MyCov
echo $MyOut
echo $MyNotes

samtools depth $MyIn > $MyCov

Rscript 2_Peakloop2.R $MyCov $MyOut > $MyNotes
