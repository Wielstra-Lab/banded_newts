#!/bin/bash

#SBATCH --ntasks=2
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --time=2-00:00:00
#SBATCH --mem=150GB
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=Ommatotriton
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stephaniekoster222@gmail.com

cd /data1/s2321041/Ommatotriton/

module load skewer
module load VCFtools
module load BWA
module load SAMtools
module load picard

perl /data1/s2321041/Ommatotriton/Scripts/1_Master_BQSR.pl
