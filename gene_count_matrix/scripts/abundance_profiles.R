# Converting the read count matrix to abundance profiles with GTDB-tk annotation

# Initializing 
library(phyloseq)
library(MASS)

# Loading relevant input
GeneLengths <- readRDS(snakemake@input[["R_gene_lengths"]]) # The gene lengths
outputs_parallel <- readRDS(snakemake@input[["MGS_object"]]) # contain the SGs of the Clusters
Clusterlist <- readRDS(snakemake@input[["R_clusters"]]) # read count matrices for the Clusters
taxonomy <- read.csv(snakemake@input[["annotation"]], header=TRUE) # the taxonomy 
colnames(taxonomy) <- c("Cluster", "Taxonomy")


#setting important variables
gene_index <- seq(1,length(GeneLengths))
gene_names <- names(GeneLengths)
n.mapped.minimum <- 3 #The number of genes that needs reads that map to count the cluster as present
n.genes <- 100 # number of signature genes

# inserting NA for the Clusters that do not have a annotation
taxmat <- matrix("NA", nrow = length(names(Clusterlist)), ncol = 7)
colnames(taxmat) <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
rownames(taxmat) <- names(Clusterlist)

for (cluster in names(Clusterlist)){
  if (cluster %in% taxonomy$Cluster){ # if the cluster is annotated
    tax <- taxonomy$Taxonomy[taxonomy$Cluster==cluster]
    tax <- substr(strsplit(tax, ";")[[1]], 4, nchar(strsplit(tax, ";")[[1]]))
    row <- rep("NA", 7)
    row[1:length(tax)] <- as.character(tax)
    taxmat[cluster,] <- row
  } 
}


# Identifying the "Maintax"
taxonomy$MainTax <- rep("NA", length(taxonomy))
count <- 0 
for (MGS in taxonomy$Cluster){
  if (length(taxonomy$Taxonomy[taxonomy$Cluster==MGS])==0){
    na_df <- data.frame(MGS, "NA;NA;NA", "NA")
    colnames(na_df) <- c("Cluster", "Taxonomy", "MainTax")
    taxonomy <- rbind(taxonomy, na_df)
    count <- count + 1
  } else {
    main_tax <- paste(tail(strsplit(taxonomy$Taxonomy[taxonomy$Cluster==MGS],";")[[1]], n=2)[1], tail(strsplit(taxonomy$Taxonomy[taxonomy$Cluster==MGS],";")[[1]], n=2)[2])
    taxonomy$MainTax[taxonomy$Cluster == MGS] <- main_tax
  }
}
rownames(taxonomy) <- taxonomy$Cluster # set the clusterID as rownames (for the phyloseq)
taxonomy$Cluster <- NULL #removing the column witht the clusterID


# The read counts are normalized according to gene lengths
init.read.matrix <- matrix(NA, nrow=dim(Clusterlist[[1]])[2], ncol=length(Clusterlist))
final.read.matrix <- matrix(NA, nrow=dim(Clusterlist[[1]])[2], ncol=length(Clusterlist))
sample.names <- colnames(Clusterlist[[1]]) 
rownames(init.read.matrix) <- sample.names # setting the sample names as rownames
rownames(final.read.matrix) <- sample.names
colnames(init.read.matrix) <- names(Clusterlist) # setting the cluster ID's as colnames
colnames(final.read.matrix) <- names(Clusterlist) 
init.Clusterlist <- Clusterlist
final.Clusterlist <- Clusterlist


for (id in names(Clusterlist)){
  #removing the samples, with less than 3 genes with mapped reads
  init.gene.names <- outputs_parallel[[id]]$genes$init
  init.colsum <- colSums(Clusterlist[[id]][init.gene.names, ])
  init.mapped <- names(init.colsum[init.colsum >= n.mapped.minimum])
  init.not_mapped <- sample.names[!sample.names %in% init.mapped]
  init.Clusterlist[[id]][,init.not_mapped] <- 0 # setting the counts to 0 if less than n.mapped.minimum genes have reads that map
  
  # The readcounts are divided by the gene length
  
  init.reads <- init.Clusterlist[[id]][init.gene.names, ] / GeneLengths[init.gene.names] 
  
  # summing the read counts for the id/cluster/MGS
  init.read.matrix[, id] <- colSums(init.reads)
  
  
  # Repeat for the final SG
  final.gene.names <- outputs_parallel[[id]]$genes$worst
  final.colsum <- colSums(Clusterlist[[id]][final.gene.names, ])
  final.mapped <- names(final.colsum[final.colsum >= n.mapped.minimum])
  final.not_mapped <- sample.names[!sample.names %in% final.mapped]
  final.Clusterlist[[id]][,final.not_mapped] <- 0 # setting the counts to 0 if less than n.mapped.minimum genes have reads that map
  
  # The readcounts are divided by the gene length
  final.reads <- final.Clusterlist[[id]][final.gene.names, ] / GeneLengths[final.gene.names]
  
  # summing the read counts for the id/cluster/MGS
  final.read.matrix[, id] <- colSums(final.reads)
}

init.abundance <- init.read.matrix/rowSums(init.read.matrix)
final.abundance <- final.read.matrix/rowSums(final.read.matrix)

init.otu.table <- otu_table(init.abundance, taxa_are_rows=FALSE) 
final.otu.table <- otu_table(final.abundance, taxa_are_rows = FALSE)
tax.table <- tax_table(taxmat)

init.physeq <- phyloseq(init.otu.table, tax.table)
final.physeq <-  phyloseq(final.otu.table, tax.table)

save(final.physeq, file = snakemake@output[["physeq_abundance"]])
