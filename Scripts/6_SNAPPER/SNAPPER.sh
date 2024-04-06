#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=3-12:00:00
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=10G
#SBATCH --partition=cpu-long
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=snapper_ommaOut16
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stephaniekoster222@gmail.com

cd /data1/s2321041/Ommatotriton/Snapper/

/data1/s2321041/beast/bin/beast -threads $SLURM_CPUS_PER_TASK OmmaOut.xml
