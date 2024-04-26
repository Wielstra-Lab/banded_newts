# Phylogenomics resolves the ancient and rapid radiation of banded newts (genus Ommatotriton)
---

The team: Konstantinos Kalaentzis, Stephanie Koster, Jan W. Arntzen, Sergé Bogaerts, James France, Michael Franzen, Christos Kazilas, Spartak N. Litvinchuk, Kurtuluş Olgun, Manon de Visser, Ben Wielstra

---
# 1 Pipeline steps
*All scripts used are found in the  folder Scripts, in the order in which they should be executed*

<details>
  
<summary> 1_Pipeline </summary>

### Pipeline for data processing

Run 1_scheduler_Master_BQSR.sh, which calls on 1_Master_BQSR.pl and 1_bbmap_repair.sh. This master script takes care of trimming, sorting, mapping, adding readgroups, variant calling and variant combining. Sample names need to be provided at the start and variant combining portions of the script, and new folders are created when needed. To check for coverage of the samples, it would be best to stop the pipeline after readgroups have been added. Then, you can loop 2_PeakShell.sh over the samples:
  
  ```
  for FILE in *.dedup.bam; do sh 2_PeakShell.sh $FILE; done
  ```

If you have a lot of samples, it may be more efficient to copy the loop into a SLURM batch script, so you can run it remotely. Ideally, we would like to have a median peak 100bp region coverage of at least 10 for each sample. Anything over 5 should be useable in a pinch, but keep in mind that you may lose a lot of data for your other samples if you do. Then, continue the pipeline to make combined VCFs for just the Ommatotriton data, and one with outgroup added.

### Heterozygote excess & missing data removal

Run 3_HWE.sh on both of the VCF files from the previous step, don't forget to give them different names. This script removes any sites that aren't in Hardy-Weinberg equilibrium, to get rid of heterozygote excess in the data. Then, run 4_Variant_selection.sh and 5_Quality_filtering.sh on the output files. These scripts filter out sites that have a quality score of less than 20, and remove any sites that are missing in 50% of 100% of the data (depending on the script). I recommend to add 0.5 or 1 to the filename, depending on how much missing data is removed according to the script, so you can still tell the files apart. Both scripts produce a .recode.vcf, which has multiple SNPs per marker, and a SNP_Subset.vcf, which only has one SNP per marker.

   </details>

# 2 PCA

<details>
  
<summary> 2_PCA </summary>

### Principal Component Analysis
Download the combined .g.vcf file without outgroups and its corresponding index file. You also need to prepare a file with sample names/codes, and the group they correspond to, in order to color the dots in the PCA by species. Follow the steps in PCA.R.

   </details>

# 3 Phylogenomics

<details>
  
<summary> 3_RAxML </summary>

### Maximum-Likelihood inference in RAxML

Take the 0.5 missing data .recode.vcf with outgroups from the Pipeline step, and (optionally) copy this to a new folder for RAxML. Run the Python 3 script vcf2phylip.py (https://zenodo.org/doi/10.5281/zenodo.1257057), after starting a Python 3 module if required;

  ```
  module load Python3
  python3 vcf2phylip.py -i OmmatotritonOut0.5.recode.vcf
  ```

Then, remove invariant sites from the data by running the Python3 script ascbias.py (https://github.com/btmartin721/raxml_ascbias) on the phylip file you obtained from the previous script;

  ```
  python3 ascbias.py -p OmmatotritonOut0.5.min4.phy
  ```

The output file will be called out.phy (by default, you can give it a custom name when running ascbias.py). Run RAxML.sh on this file. After this has finished running, open the bipartitions file in FigTree and reroot the tree on the branch between Triturus and Ommatotriton to obtain the RAxML tree with bootstrap values. Do the same for the bestTree to get one of the input files for TreePL.

   </details>

<details>
  
<summary> 4_treePL </summary>

### Dated phylogeny in TreePL
First, install treePL if you don't already have it. I installed it via Conda.

TreePL needs three things to make a dated phylogeny with confidence intervals; (a) calibration point(s), a bestTree without bootstap values (obtained from the previous step) and bootstrap replicates with the same topology as this bestTree. If the topology is different, the confidence intervals will become very wide and useless. To obtain the bootstrap replicates, rerun RAxML, but constrain the outgroup this time (see script in the treePL folder). For a less complex outgroup, constraining via a starting tree may work, but in our case it only put one of the Triturus species as outgroup when we tried that.

Before actually inferring a dated tree, priming analyses need to be run. Add the number of distinct alignment patterns and the calibration points to the treePL file. Comment out the line referring to the bootstrap trees, 



   </details>

 <details>
  
<summary> 5_ASTRAL </summary>

### To come


   </details>  

<details>
  
<summary> 6_SNAPPER </summary>

### To come


   </details>
   


# 4 Introgression analyses

<details>
  
<summary> 7_TreeMix </summary>

### To come


   </details>


 <details>
  
<summary> 8_Phylonet </summary>

### To come


   </details>  
