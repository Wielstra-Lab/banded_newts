#!/bin/bash

#SBATCH --ntasks=4
#SBATCH --time=1-12:00:00
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=PGD_VCF2PHY
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kostersca@vuw.leidenuniv.nl

cd /data1/s2321041/Ommatotriton/ASTRAL/2_vcf2phy/

## Bash Script to loop PGDSpider
## Input files have .vcf extension, output files .phy. -Xmx5g indicates that java is allowed 5Gb memory.

for file in /data1/s2321041/Ommatotriton/ASTRAL/2_vcf2phy/*.vcf
do
java -Xmx5g -jar /data1/s2321041/Ommatotriton/ASTRAL/2_vcf2phy/PGDSpider2-cli.jar -inputfile "$file" -outputfile "${file%.vcf}.phy" -inputformat VCF -outputformat PHYLIP -spid VCF_to_PHYLIP.spid
done
