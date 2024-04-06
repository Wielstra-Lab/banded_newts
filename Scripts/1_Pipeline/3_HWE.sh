#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --time=0-01:00:00
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=HetExc
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stephaniekoster222@gmail.com

cd /data1/s2321041/Ommatotriton/variants/

module load BCFtools

bcftools +fill-tags Ommatotriton.g.vcf -Ou -- -t all | bcftools view -e'ExcHet<0.05' > Ommatotriton_Exchet.vcf # creates a new .vcf file excluding the sites with heterozygote excess
