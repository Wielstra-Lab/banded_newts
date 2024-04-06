#!/bin/bash

#SBATCH --ntasks=4
#SBATCH --time=1-12:00:00
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=invariant
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stephaniekoster222@gmail.com

## Bash Script to loop python script

cd /data1/s2321041/Ommatotriton/ASTRAL/2_vcf2phy

module load Python/3.7.4-GCCcore-8.3.0

for file in *.phy
do
python3 /home/s2321041/ascbias.py -p "$file" -o /data1/s2321041/Ommatotriton/ASTRAL/3_RAxML/"${file%.phy}_unInv.phy"
done
