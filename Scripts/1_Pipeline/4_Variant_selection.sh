#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --time=0-01:00:00
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=variant_selection
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stephaniekoster222@gmail.com

cd /data1/s2321041/Ommatotriton/variants/

module load VCFtools

vcftools --vcf OmmatotritonOutgroups_Exchet.vcf --max-missing 0.5 --remove-indels --minQ 20 --recode --recode-INFO-all --out OmmaOut_filtered

perl /data1/s2321041/Ommatotriton/RAxML/4_subsampleVCF.pl OmmaOut_filtered.recode.vcf OmmaOut_SNPs_Subset.vcf
