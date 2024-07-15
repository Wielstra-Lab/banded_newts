#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --time=2-00:00:00
#SBATCH --job-name=RAxML_Ommatotriton
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kostersca@vuw.leidenuniv.nl

###Ortiz, E.M. 2019. vcf2phylip v2.0: convert a VCF matrix into several matrix formats for phylogenetic analysis. DOI:10.5281/zenodo.2540861
###ascbias.py: https://github.com/btmartin721/raxml_ascbias

cd /data1/s2321041/Ommatotriton/treePL/

/home/s2321041/standard-RAxML-8.2.12/raxmlHPC-PTHREADS-SSE3 -T 2 -m ASC_GTRGAMMA --asc-corr=lewis -o 1995_Triturus_marmoratus,7781_Triturus_marmoratus,5017_Triturus_marmoratus,312_Triturus_carnifex,292_Triturus_carnifex,405_Triturus_carnifex,3247_Triturus_macedonicus,3275_Triturus_macedonicus,3775_Triturus_macedonicus -n OmmaBoot.tre -s "out.phy" -O -x 4 -N 100 -k -p 368 -w "/data1/s2321041/Ommatotriton/treePL"
