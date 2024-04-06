#!/bin/bash
#Written by M.C. de Visser

#This script will make sure the R1 and R2 FASTQ files obtained after BBduk + Trimming are actually sorted/in sync again.
#This is necessary because otherwise BWA will not recognize read pairs that belong to each other, and hence mapping will fail
#This failure does not always occur, but sometimes it does, so if applicable this script can be run (included in master pipeline)

cd skewer/

#BBmap requires unzipped files to work with, so we gunzip everything:
for file in *.gz; do gunzip $file; done



#This oneliner - which I luckily found on this great thing called the internet - can be used to automatically detect the R1 and R2 files 
#that belong to each other and will run the repair.sh script accordingly (make sure this script is in the righ place in your Linux environment)
for file in `ls -1 *pair1.fastq | sed 's/-trimmed-pair1.fastq//'` ; do /home/s2321041/bbmap/repair.sh in1=$file\-trimmed-pair1.fastq in2=$file\-trimmed-pair2.fastq out1=$file\-trimmed-fixed-pair1.fastq out2=$file\-trimmed-fixed-pair2.fastq; done



#For the rest of the master pipeline we continue using zipped files again, so gzip
for file in *fixed*.fastq; do gzip $file; done



#And lastly, we now have some intermediate/old, gunzipped files remaining that just take up storage. So remove those:
for file in *.fastq; do rm $file; done

cd ../
