#!/bin/bash

#SBATCH --ntasks=2
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --time=3-00:00:00
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=Phylonet
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kostersca@vuw.leidenuniv.nl

cd /data1/s2321041/Ommatotriton/Phylonet/

java -jar /data1/s2321041/PhyloNet.jar OmmaAll1.tree > ret1.out1.txt
