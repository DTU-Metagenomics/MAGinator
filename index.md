# MAGinator
## Introduction
This is a collection of tools that should help with downstream analysis of data obtained from metagenomic binners such as Vamb or MSPMiner.
Vamb provides not only the binning clusters of all related contigs but also the bins obtained from individual samples and like many other programs allows a lot of options. Be aware that your question should dictate your workflow but I am providing information about how I run Vamb to allow better reproduction and as inspiration.
The provided scripts are all made for high-performance computing servers using a TORQUE Resource Manager and more specifically tested/running on [Computerome 2.0](https://www.computerome.dk/display/C2W/Computerome+2.0). The goal is to provide a snakemake worfklow incorporating conda environments for a user-friendly and reproducible workflow.
<img align="center" src="https://github.com/DTU-Metagenomics/MAGinator/blob/gh-pages/workflow.png?raw=true" width="600">
### Binning using Vamb
This example binning workflow was used for fecal samples. It is provided mainly to allow reproduction, but can of course be used. Remember to adjust according to your data and hypothesis. You should also check input/output using [FastQC](https://github.com/s-andrews/FastQC) at every step to insure optimal quality. For VAMB documentation look at [Vambs](https://github.com/RasmussenLab/vamb) Github which now includes a snakemake! <br>
#### Overview
1. [This script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Scripts/qsub_bbduk_KTrim.sh) removes adapter sequence from raw reads using [bbduk](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/).
2. [This script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Scripts/qsub_sickle.sh) performs trimming of low quality sequence using [Sickle](https://github.com/najoshi/sickle).
3. [This script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Scripts/qsub_bbmap_Decon.sh) removes host contamination [bbmap](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/).
4. [This script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Scripts/qsub_spades.sh) does assembly using [Spades](https://github.com/ablab/spades).
5. We need to set a lower-cutoff limit for contig size. You can use [this script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Scripts/qsub_batch_fasta_select.sh).
6. [This script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Scripts/qsub_minimap2_index.sh) indexes contigs for [Minimap2](https://github.com/lh3/minimap2).
7. [This script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Scripts/qsub_minimap2_align.sh) maps reads using [Minimap2](https://github.com/lh3/minimap2)
8. [This script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Scripts/qsub_fasta_coverage.sh) analyses the contig coverage using JGIs [jgi_summarize_bam_contig_depths](https://bitbucket.org/berkeleylab/metabat/src/master/), which is actually part of the Metabat binner.
9. Now we are ready to bin using [this script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Scripts/qsub_vamb_bin.sh) which is running the GPU-accelerated [VAMB](https://github.com/RasmussenLab/vamb).
## Installation on Linux
MAGinator uses conda environments and snakemake. First you will need to install [miniconda](https://docs.conda.io/en/latest/miniconda.html) with Python 3.9. We download miniconda:
> wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh <br>
> bash Miniconda3-py39_4.9.2-Linux-x86_64.sh

Follow the instructions and remember to install miniconda in an appropriate location.
You will also need the package manager mamba
> conda install -c conda-forge mamba

## Postprocessing contig-based bins from VAMB
<img align="right" src="https://github.com/DTU-Metagenomics/MAGinator/blob/gh-pages/plot_binsizes.png?raw=true" width="500">

The binning workflows suggested do not have a lower cut-off for bins. This means that we will have many small bins of which some will be of little use.
We want to separate bins into potential MAGs (Metagenome-Assembled Genomes) and extrachromosomal elements. Some bins containing MAGs will also contain viruses and plasmids but are apparently so associated with one specific organism that it makes biological sense to leave them together with their host. However, for analyzing extrachromosomal elements we will of course include these as well. As seen on the figure chromosomes smaller than 200,000bp are the exception thus I have set the cut-off here. You can copy all bins larger than your wanted cut-off  using this [script](https://github.com/DTU-Metagenomics/MAGinator/blob/main/Bin/fasta_select_file_size.py). It also provides a visualization of ALL bins and shows your cut-off as a red line.

## Analyzing Metagenome-Assembled Genomes
Now that we have separated potential MAGs (bins larger than our cut-off), we would like to do some quality control. [CheckM](https://ecogenomics.github.io/CheckM/) uses lineage-specific marker gene sets to gauge to completness and level of contamination in each bin. CheckM is also included in the VAMB Snakemake workflow.

###  Assessment of genome quality

### Taxonomy of bins

### Gene-catalogues of binning clusters
[This Snakefile](https://github.com/DTU-Metagenomics/MAGinator/blob/main/gene_count_matrix/Snakefile_VAMBgenes) takes the sequences of VAMB clusters and produces a gene count matrix of the nonredundant genes for each cluster (also excluding representative sequences). 

The rulegraph of the suggested pipeline is seen as:
<img src="https://raw.githubusercontent.com/gisleDK/MAGinator/main/gene_count_matrix/rulegraph.svg">

### Binning clusters signature genes

### Binning clusters phylogeny

### Binning clusters phylogeny

### Abundance of bins

## Analyzing Extrachromosomal elements
