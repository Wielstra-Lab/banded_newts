#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --time=0-01:00:00
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=TreePL_Ommatotriton
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kostersca@vuw.leidenuniv.nl

cd /data1/s2321041/Ommatotriton/treePL/

source /cm/shared/easybuild/software/AMUSE-Miniconda2/4.7.10/etc/profile.d/conda.sh
conda activate /data1/s2321041/treepl

/data1/s2321041/treepl/treePL 2_Omma_treePL.txt
