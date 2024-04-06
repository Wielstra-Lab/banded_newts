#!/usr/bin/perl -w  #this enables useful warnings
#Originally written by E. McCartney-Melstad
#Adjusted by M.C. de Visser



use strict;                    # uses ' vars' , ' refs' , and ' subs' , to generate errors in case empty variables, symbolic references or bareword identifiers are used in improper ways
use warnings;                  # if triggered, it will indicate a ' problem '  exists, generates an error
use Parallel::ForkManager;     # used to perform a number of repetitive operations withing a single Perl script




#######################
### Specify samples ###
#######################

### Here you specify your sample names, it may seem like a tedious task, but with a known list of your samples and some basic REGEX 
### / manipulation commands you can easily create the required text without manually having to type it all

#######################

#First tested it with two parents
my @samples = ("292_Triturus_carnifex", 
"312_Triturus_carnifex", 
"405_Triturus_carnifex", 
"1995_Triturus_marmoratus", 
"3247_Triturus_macedonicus", 
"3275_Triturus_macedonicus", 
"3775_Triturus_macedonicus", 
"5017_Triturus_marmoratus", 
"7781_Triturus_marmoratus", 
"ISVIT1", 
"NES007", 
"NES031", 
"NES172", 
"NES206", 
"NES581", 
"OPH299", 
"OPH377", 
"OPH491", 
"OPH676", 
"OPH690", 
"VIT610", 
"VIT612", 
"VIT619", 
"VIT654");
#Now running it on all my samples in one go, after organizing everything on ALICE & RD

print "Processing " . scalar(@samples) . " samples\n";   




####################################
### Trim 151st bp off with BBDuk ###
####################################

### First we want to get rid of the 151st bp that many reads have, which could be prone to error. 
### Adjust the BBduk folder name and the path+names of your desired in- and output files. Adjust the forkmanager number appropriately
### NEED TO REMOVE _001_AHVV55DRX2 LATER

my @BBdukCommands;
foreach my $sample (@samples) {
    my $R1 = "/data1/s2321041/Ommatotriton/" . $sample . "_R1.filt.fastq.gz";
    my $R2 = "/data1/s2321041/Ommatotriton/" . $sample . "_R2.filt.fastq.gz";
    
    #Make sure this bbmap/bbduk shell script is actually in the right place
    my $BBdukscript = "~/bbmap/bbduk.sh";

    my $BBdukBaseNameR1 = "BBduk_all_R1/" . $sample . "_150_R1.fastq.gz";
    my $BBdukBaseNameR2 = "BBduk_all_R2/" . $sample . "_150_R2.fastq.gz";

    push(@BBdukCommands, "$BBdukscript -Xmx4g in=$R1 out=$BBdukBaseNameR1 ftr=149");
    push(@BBdukCommands, "$BBdukscript -Xmx4g in=$R2 out=$BBdukBaseNameR2 ftr=149");
}

print ">>>>Running all BBduk commands\n";

my $BBdukFM = Parallel::ForkManager->new(16);
foreach my $BBdukCommand(@BBdukCommands) {
    $BBdukFM->start and next;
    print "Running the following command: \n$BBdukCommand\n";
    system($BBdukCommand);
    $BBdukFM->finish;
}
$BBdukFM->wait_all_children();

print "\n\n>>>>Finished running all BBduk commands\n\n";




################
### TRIMMING ### This part is optimized now!!!
################

### Here we trim universal adapters and low quality bases/reads
### Adjust the skewer folder name and the path+names of your desired in- and output files. Adjust the forkmanager number appropriately.

################

unless (-d "skewer") {
    mkdir "skewer";
}

my @skewerCommands;
foreach my $sample (@samples) {
    my $R1 = "/data1/s2321041/Ommatotriton/BBduk_all_R1/" . $sample . "_150_R1.fastq.gz";
    my $R2 = "/data1/s2321041/Ommatotriton/BBduk_all_R2/" . $sample . "_150_R2.fastq.gz";
     
    my $adapterFile = "/data1/projects/pi-vissermcde/Triturus_reference/universal.adapters.fa";
 
    #Make sure the adapter file exists
    unless (-e $adapterFile) {die "$adapterFile not present!\n";}

    my $skewerBaseName = "skewer/" . $sample;

    push(@skewerCommands, "/cm/shared/easybuild/software/skewer/0.2.2-foss-2019b/bin/skewer -Q 15 -q 20 -t 2 -x $adapterFile -m pe $R1 $R2 -l 100 -z -o $skewerBaseName");  
}
 
print ">>>>Running all skewer commands\n";

my $skewerFM = Parallel::ForkManager->new(16);
foreach my $skewerCommand(@skewerCommands) {
    $skewerFM->start and next;
    print "Running the following command: \n$skewerCommand\n";
    system($skewerCommand);
    $skewerFM->finish;
}
$skewerFM->wait_all_children();

print "\n\n>>>>Finished running all skewer commands\n\n";




###########################
### SORT TRIMMED FASTQs ###
###########################

### NEW / UPDATE - @MSC STUDENTS, SEE E-MAIL 10 JUNE 2022!
### Running this script will make sure the R1 and R2 FASTQ files obtained after BBduk + Trimming are actually sorted/in sync again.
### This is necessary because otherwise BWA will not recognize read pairs that belong to each other, and hence mapping will fail
### This failure does not always occur, but sometimes it does, so if applicable this script can be run (included in master pipeline)

### ADJUST YOUR PATH to the place where you have the (correct version of) your bash script, bbmap_repair.sh, which will in turn run the BBmap script repair.sh 

print "\n\n >>>>Sorting trimmed fastqs using BBmap\n\n";
  
system("/data1/s2321041/Ommatotriton/Scripts/1_bbmap_repair.sh");

print "\n\n >>>>Finished sorting trimmed fastqs using BBmap\n\n";





###############
### MAPPING ### This part is optimized now!!!
###############

### Here we align the reads to a reference / we map the reads and create BAM files, which are compressed SAM files
### Adjust the mapping folder name and the path+names to your trimmed file location. Adjust the forkmanager number appropriately.

###############

print "\n\n >>>>Mapping reads using BWA MEM\n\n";

unless (-d "mapping") {
    mkdir "mapping";
}
my $bwaFM = Parallel::ForkManager->new(16);
foreach my $sample (@samples) {
    $bwaFM->start and next;
    my $R1 = "skewer/" . $sample . "-trimmed-fixed-pair1.fastq.gz";
    my $R2 = "skewer/" . $sample . "-trimmed-fixed-pair2.fastq.gz";
    my $bam = "mapping/" . $sample . ".bam";

    system("/cm/shared/easybuild/software/BWA/0.7.17-GCC-10.2.0/bin/bwa mem -M /data1/projects/pi-vissermcde/Triturus_reference/triturus.RBBH.fasta $R1 $R2 | /cm/shared/easybuild/software/SAMtools/1.12-GCC-10.2.0/bin/samtools view -bS - > $bam");
    $bwaFM->finish;
}
$bwaFM->wait_all_children();

print "\n\n >>>>Finished mapping reads using BWA mem\n\n";




##############
### ADD RG ### This part is optimized now!!!
##############

### Here we'll add RG information using picard AddOrReplaceReadGroups and mark duplicates
### Adjust the path+names of the desired in- and output (so location to bam files) for the Read Group (RG) and Mark Dupliates (MD) steps, so twice
### Also adjust the list file path+names in the end. Adjust the forkmanager number appropriately.

### Be aware that with these settings, Picard does not distinguish between different runs or lanes
### so if you leave these settings for the whole bulk/all your samples, there will be no correction of in-between-run technical biases.
### If you do want to do that, you will need to adjust the RGLB and PU information in more detail and run it for each sample/batch/run separately/specifically.
### Here I use RGLB -lib1, so everything is assumed to be a unique/one library (if one sample occurs twice under a different name, it will not be recognized as the same sample obviously,
### also if you combined reads from different runs of one sample into one fastq file, of course Picard is also unable to recognize reads from one or the other run, so be careful with that).

##############

my $addReplaceFM = Parallel::ForkManager->new(16);
print "\n\nAdding read groups and marking duplicates with picard\n\n";
foreach my $sample (@samples) {
    $addReplaceFM->start and next;

    my $input = "/data1/s2321041/Ommatotriton/mapping/$sample.bam";
    my $output = "/data1/s2321041/Ommatotriton/mapping/$sample.RG.bam";
    my $SM = $sample;
    my $RGLB = $SM . '-lib1';
    my $RGID = $sample;

    system("java -jar \$EBROOTPICARD/picard.jar AddOrReplaceReadGroups I=$input O=$output RGLB=$RGLB RGPL=ILLUMINA RGSM=$SM RGID=$RGID RGPU=NA SORT_ORDER=coordinate TMP_DIR=/data1/s2321041/Ommatotriton");
                     #RGPU=NA --> note that this means that picard does not distinguish now between different runs or lanes, so we do not correct for technical biases - also it is assumed here that you have reads from just 1 'library', or 'run', per sample
 
    my $MDout = "/data1/s2321041/Ommatotriton/mapping/$sample.dedup.bam";
    my $metrics = "/data1/s2321041/Ommatotriton/mapping/$sample.dedup.metrics";
    system("java -jar \$EBROOTPICARD/picard.jar MarkDuplicates I=$output O=$MDout M=$metrics");
    system("samtools index $MDout");
    unlink($input, $output);
    $addReplaceFM->finish;
}
$addReplaceFM->wait_all_children();
print "\n\n >>>>Finished adding read groups and marking duplicates with picard\n\n";

open(my $bqFH, ">", "/data1/s2321041/Ommatotriton/.dedupBams.list");
foreach my $sample (@samples) {
	print $bqFH "/data1/s2321041/Ommatotriton/mapping/$sample.dedup.bam" . "\n";
}
close($bqFH);




#######################
### VARIANT CALLING ### This part is optimized now!
#######################

### Here we will do the first round of variant calling, which will generate raw g.vcf files
### Those will be used to do hard filtering on, to go for a subset of SNPs that we trust, and those
### will in turn be used by BQSR later on to re-do and optimize the variant calling overall

### Adjust the variants folder name and the path+names of the desired in- and output. Adjust the forkmanager number accordingly.

#######################

unless(-d "variants") {
    mkdir("variants");
}
print "\n\nRunning haplotypeCaller to generate pre-BQSR g.vcfs\n\n";

my $hapCallerFM = Parallel::ForkManager->new(16);
foreach my $sample (@samples) {
    $hapCallerFM->start and next;
    my $inputBAM = "mapping/" . $sample . ".dedup.bam";
    my $gVCF = "variants/" . $sample . ".raw.g.vcf";

    system("/cm/shared/easybuild/software/GATK/4.1.3.0-GCCcore-8.3.0-Java-1.8/gatk --java-options '-DGATK_STACKTRACE_ON_USER_EXCEPTION=true' HaplotypeCaller --reference /data1/projects/pi-vissermcde/Triturus_reference/triturus.RBBH.fasta -ERC GVCF -I $inputBAM -O $gVCF --tmp-dir ~/data1/Ommatotriton"); 
    $hapCallerFM->finish;
}

$hapCallerFM->wait_all_children();

print "\n\nFinished running first round of haplotypeCaller to generate pre-BQSR, raw gvcfs\n\n";




############################
### GenomicsDBImport, ERC### This part is optimized now! 
############################

### Here we'll combine the gvcfs, and then perform joint-genotype calling, to create the raw, pre-BQSR, multi-sample gVCF file
### Adjust the list of Variants accordingly. Again this may seem like a tedious task, but when you have a list of your sample names, you can use 
### basic REGEX / manipulation commands to generate the right text instead of typing it all. It will be a long list if you have hundreds of
### samples, because this command does not allow to use the for loop/push through each sample separately, so be careful here not to miss a sample, or add one non-existing one.
### Also adjust the path/name of the desired database in the GenomicsDBImport step, and the same database name as input in the GenotypeGVCFs step. 
### And adjust the desired output in the latter.

############################

print "\n\nCombining gvcfs with GDBI to generate pre-BQSR ms-gVCF file to use for joint-genotype calling\n\n";

system("/cm/shared/easybuild/software/GATK/4.2.2.0-GCCcore-10.2.0-Java-11/gatk --java-options '-Xms800m -Xmx100g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true' GenomicsDBImport" .
" -V ./variants/292_Triturus_carnifex.raw.g.vcf" .
" -V ./variants/312_Triturus_carnifex.raw.g.vcf" .
" -V ./variants/405_Triturus_carnifex.raw.g.vcf" .
" -V ./variants/1995_Triturus_marmoratus.raw.g.vcf" .
" -V ./variants/3247_Triturus_macedonicus.raw.g.vcf" .
" -V ./variants/3275_Triturus_macedonicus.raw.g.vcf" .
" -V ./variants/3775_Triturus_macedonicus.raw.g.vcf" .
" -V ./variants/5017_Triturus_marmoratus.raw.g.vcf" .
" -V ./variants/7781_Triturus_marmoratus.raw.g.vcf" .
" -V ./variants/ISVIT1.raw.g.vcf" .
" -V ./variants/NES007.raw.g.vcf" .
" -V ./variants/NES031.raw.g.vcf" .
" -V ./variants/NES172.raw.g.vcf" .
" -V ./variants/NES206.raw.g.vcf" .
" -V ./variants/NES581.raw.g.vcf" .
" -V ./variants/OPH299.raw.g.vcf" .
" -V ./variants/OPH377.raw.g.vcf" .
" -V ./variants/OPH491.raw.g.vcf" .
" -V ./variants/OPH676.raw.g.vcf" .
" -V ./variants/OPH690.raw.g.vcf" .
" -V ./variants/VIT610.raw.g.vcf" .
" -V ./variants/VIT612.raw.g.vcf" .
" -V ./variants/VIT619.raw.g.vcf" .
" -V ./variants/VIT654.raw.g.vcf" .
" --max-num-intervals-to-import-in-parallel 20 --genomicsdb-workspace-path my_database_all_ERC" .
" --intervals /data1/projects/pi-vissermcde/Triturus_reference/sorted_ref_RBBH_targetnames.list --merge-contigs-into-num-partitions 1 --tmp-dir ~/data1/Ommatotriton");#

print "\n\nFinished combining gvcfs with GDBI to generate pre-BQSR ms-gVCF file to use for joint-genotype calling\n\n";


### Here we'll perform joint-genotype calling as to truly 'fill in' the merged gVCF file with the correct genotypes/SNP calls

print "\n\nPerforming joint-genotype calling using the created database\n\n";

system("/cm/shared/easybuild/software/GATK/4.2.2.0-GCCcore-10.2.0-Java-11/gatk --java-options '-Xms800m -Xmx110g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true' GenotypeGVCFs" .
" -R /data1/projects/pi-vissermcde/Triturus_reference/triturus.RBBH.fasta" .
" -V gendb://my_database_all_ERC" .
" -O /data1/s2321041/Ommatotriton/variants/OmmatotritonOutgroups.g.vcf" .
" --tmp-dir ~/data1");

print "\n\nFinished joint-genotype calling, created pre-BQSR raw ms-gVCF\n\n";

print "\n\nFinished joint-genotype calling, created pre-BQSR raw ms-gVCF. NOW GO CELEBRATE :)\n\n";
