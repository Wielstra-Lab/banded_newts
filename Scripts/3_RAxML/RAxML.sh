#!/bin/bash

#SBATCH --ntasks=2
#SBATCH --mem=150GB
#SBATCH --partition=cpu_natbio
#SBATCH --output=output_%j.txt
#SBATCH --time=2-00:00:00
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=RAxML_Ommatotriton
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s.c.a.koster@umail.leidenuniv.nl

###Ortiz, E.M. 2019. vcf2phylip v2.0: convert a VCF matrix into several matrix formats for phylogenetic analysis. DOI:10.5281/zenodo.2540861
###ascbias.py: https://github.com/btmartin721/raxml_ascbias

cd /data1/s2321041/Ommatotriton/RAxML/

/home/s2321041/standard-RAxML-8.2.12/raxmlHPC-PTHREADS-SSE3 -T 2 -f a -x 609516 -p 609516 -N 100 -m ASC_GTRGAMMA --asc-corr=lewis -O -n OmmaOut.tre -s "out.phy" -w "/data1/s2321041/Ommatotriton/RAxML"
