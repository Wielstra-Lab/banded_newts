#!/bin/bash

#SBATCH --ntasks=4
#SBATCH --time=2-12:00:00
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=ASTRAL_RAxML
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stephaniekoster222@gmail.com

## Bash Script to loop RAxML script

cd /data1/s2321041/Ommatotriton/ASTRAL/3_RAxML/

for file in *.phy
do
/data1/s2321041/Ommatotriton/ASTRAL/3_RAxML/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 2 -f a -x 124473 -p 124473 -N 100 -m ASC_GTRGAMMA --asc-corr=lewis -O -n ${file%.phy}.tre -s "$file" -w "/data1/s2321041/Ommatotriton/ASTRAL/3_RAxML"
done
