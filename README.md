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
  
<summary> 4_TreePL </summary>

### Dated phylogeny in TreePL
First, install treePL if you don't already have it. I installed it via Conda.

TreePL needs three things to make a dated phylogeny with confidence intervals; (a) calibration point(s), a bestTree without bootstap values (obtained from the previous step) and bootstrap replicates with the same topology as this bestTree. If the topology is different, the confidence intervals will become very wide and useless. To obtain the bootstrap replicates, rerun RAxML, but constrain the outgroup this time (see script in the treePL folder). For a less complex outgroup, constraining via a starting tree may work, but in our case it only put one of the Triturus species as outgroup when we tried that.

Before actually inferring a dated tree, priming analyses need to be run to determine the proper parameters. Add the number of distinct alignment patterns and the calibration points to the treePL file. Comment out the line referring to the bootstrap trees, and leave the prime command uncommented. The parameters under [Cross-validation analysis] and [Output file of dating step] should be commented out here. [Best optimisation parameters] and [Best smoothing value] should be empty at this point, or else commented out. Run treePL like this;

  ```
  /path/to/treepl/installation/treePL 2_Omma_treePL.txt
  ```

When this is done running, it will suggest several parameters. Write these down, and repeat this step a few times. Add the most commonly suggested parameters and the lowest values for opt and optad to the configuration file under [Best optimisation parameters], this bit should now be uncommented. Comment out the prime command and uncomment the parameters under [Cross-validation analysis]. 

Rerun treePL to get cross-validation values from which to determine the smoothing value. If you get a might want to try a different opt=VALUE (or optad=VALUE), incrementally increase this until no more messages show up when rerunning. The results of cross-validation will be written to a file. Run this step a few times to find the lowest value it stabilizes at. This will be the smoothing value, add it to the file.

Comment out the parameters under [Cross-validation analysis] and the bestTree input, and uncomment the bootstrap tree input, smoothing value and [Output file of dating step]. Run treePL one last time to obtain the dated trees. Download this file, and combine the trees in TreeAnnotator with 0% burnin and mean node heights. Load the resulting file into FigTree and add the confidence interval bars and a scale bar.

More info on treePL can be found here: https://www.researchgate.net/publication/343708533_An_empirical_guide_for_producing_a_dated_phylogeny_with_treePL_in_a_maximum_likelihood_framework

   </details>

 <details>
  
<summary> 5_ASTRAL </summary>

### Summary multi-species coalescent in ASTRAL

Take the .recode.vcf without missing data, but with outgroups. Install SnpEff. Move the .vcf to the folder with the SnpSift.jar file, and use this command to split the file into separate files per site;

  ```
  java -jar SnpSift.jar split file.vcf
  ```

Run 1_vcf2phy.sh on the .vcf files to convert them to phylip format. Remove the .vcf files, then run 2_Invariant_loop.sh. Remove the .stamatakis and .felsenstein files, and loop RAxML over the out.phy files using the 3_RAxML_loop.sh script. Combine all bestTree files;

  ```
  cat ./*bestTree* OmmaBest.tre
  ```

Make a mapping.txt file, and then run ASTRAL on the concatenated tree file;

  ```
  java -jar /path/to/Astral/astral.5.7.7.jar -i OmmaBest.tre -o OmmaASTRAL.tre -a 4_mapping.txt
  ```

Visualize the output in FigTree.

   </details>  

<details>
  
<summary> 6_SNAPPER </summary>

### Bayesian species tree inference via diffusion model in SNAPPPER

Use the SNPs_Subset.vcf without missing data. I ran this both with and without outgroup.

Use the vcf2phylip.py script to convert the .vcf to a binary nexus file;

  ```
  python3 vcf2phylip.py -i Ommatotriton_SNPs_Subset.vcf --nexus-binary
  ```

Download the binary nexus file and open it in BEAUti via SNAPPER template. Keep the default settings, and only add species data to the samples. Save as an .xml. Then run SNAPPER using the SNAPPER.sh script. I ran several replicates with and without outgroup. Download the .trees files and use TreeAnnotator to combine all trees in a single file into one, with 10% burnin. Compare the replicates to each other in Tracer to see whether they converge. Converging replicates can be combined in LogCombiner, to obtain a phylogeny with higher ESS values.


   </details>
   


# 4 Introgression analyses

<details>
  
<summary> 7_TreeMix </summary>

### Introgression analysis in TreeMix

First, install TreeMix and Stacks (I did so via Conda again). Take the regular .g.vcf file without outgroups, I removed the .g bit for convenience. Then run the following code to remove missing data from the file;

  ```
  gzip Ommatotriton.vcf
  FILE=Ommatotriton
  mkdir TreeMix
  cd TreeMix
  module load VCFtools/0.1.16-foss-2018b-Perl-5.28.0
  vcftools --gzvcf /path/to/vcf/$FILE.vcf.gz --max-missing 1 --recode --stdout | gzip > $FILE.noN.vcf.gz
  ```

Then, use plink to remove any sites that are in linkage disequilibrium, and use sed to separate the chromosome name from the location id in the output file;

  ```
  VCF=Ommatotriton.noN.vcf.gz
  /path/to/plink --vcf $VCF --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 50 10 0.1 --out Omma

  sed -i 's/subseq:/subseq /g' Omma.prune.in
  ```

Prune the file based on the prune.in file;

  ```
  vcftools --gzvcf Ommatotriton.noN.vcf.gz --out Ommatotriton.pruning --positions Omma.prune.in --stdout --recode > Ommatotriton.LDpruned.vcf
  ```

Use Stacks and a pop.tsv file to add population data to the file;

  ```
  conda activate /path/to/TreeMix
  populations --in-vcf Ommatotriton.LDpruned.vcf --treemix -O ./ -M pop.tsv
  ```

Remove the first line from the resulting output file, and zip it with gzip. Then, run TreeMix;

  ```
  for i in {0..5}; do treemix -i Ommatotriton.LDpruned.p.treemix.gz -m $i -o Ommatotriton.LDpruned.$i -root Nesterovi -bootstrap -k 500 > treemix_${i}_log; done
  ```

Visualize the output using the TreeMix.R script.

   </details>


 <details>
  
<summary> 8_Phylonet </summary>

### Introgression analysis using Phylonet

Run the ASTRAL steps again on the file without the outgroups, until you obtain gene trees. Combine these in one file, and edit the file so they are numbered;

  ```
  cat *bestTree* > OmmaAll.tre
  awk '{ printf " = "; print }' OmmaAll.tre > OmmaAll1.tre
  nl -ba -w1 -s ' ' OmmaAll1.tre > OmmaAll2.tre
  awk '{ printf "Tree "; print }' OmmaAll2.tre > OmmaAll3.tree
  ```

Open the last file, and add this to the top:

#Nexus
begin trees;

Add your best RAxML tree in Newick format to the bottom of the file, and format and number this like the gene trees. Then, add this to the bottom of the file:

end;
begin phylonet;
InferNetwork_MP (1-5008) 1 -s 5009 -fs -di -pl 4 -x 20;
end;

5008 is the number of gene trees to be used for the analysis, and 5009 is the best RAxML tree that will be used to constrain the network. Run Phylonet on this file using the Phylonet1-1.sh script. It is recommended to run a few replicates for each amount of migration edges. To run Phylonet for more migration edges, change the 1 to the value you want.

You can also create a null hypothesis by adding [] around the InferNetwork_MP line, and adding this above that line:

Infer_ST_MDC (1-5008);

Then change the command in the script to this:

java -jar /data1/s2321041/PhyloNet.jar OmmaAll3.tree > MDC.out1.txt

   </details>  
