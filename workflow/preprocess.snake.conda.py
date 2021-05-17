##############################################################################################

#This Snakefile filters bins according to size

#input is a directory filled with concatenated fasta files

# The output is:
#	Filtered_bins/: This directory contains all filtered fasta files
#	bin_sizes.tsv: File showing the collective size of each bin
#	plot_binsizes.png: Plot showing the size of all bins and the used cut-off

##############################################################################################

#!/usr/bin/env python
import os
import sys



# Run R script to visualize bin sizes and used cut-off
rule visualize_bins:
    input:
        "VAMB_genes/prodigal_genes/mmseqs_95id/all_genes95_cluster.tsv"
    output:
        "VAMB_genes/prodigal_genes/mmseqs_95id/redundant_genes.tsv"
    threads: 1
    resources:
        mem_gb = 50,
        runtime = 86400
    shell: 
        "awk '$1!=$2' {input} | cut -f2 | uniq > {output}"
echo 
Rscript ~/Github/Metagenomic-bin-processor/Bin/fasta_select_file_size.r $LIST $INT

