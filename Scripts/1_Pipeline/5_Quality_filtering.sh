#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --time=0-01:00:00
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=quality_filtering
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kostersca@vuw.leidenuniv.nl

cd /data1/s2321041/Ommatotriton/variants

module load VCFtools

vcftools --vcf Ommatotriton_Exchet.vcf --max-missing 1 --remove-indels --minQ 20 --recode --recode-INFO-all --out Ommatotriton

perl /data1/s2321041/Ommatotriton/Scripts/5_SNP_Subset.pl Ommatotriton.recode.vcf Ommatotriton_SNPs_Subset.vcf
