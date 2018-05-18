# Load libraries
suppressMessages(library(vsn))
suppressMessages(library(tximport))
suppressMessages(library(readr))
suppressMessages(library(stringr))
suppressMessages(library(assertr))
suppressMessages(library(DESeq2))
suppressMessages(library(ggplot2))
suppressMessages(library(wasabi))
suppressMessages(library(apeglm))
suppressMessages(library(sleuth))
suppressMessages(library(pheatmap))
suppressMessages(library(regionReport))

# Store DESeq2 results
dir.create('results', showWarnings = FALSE, recursive = TRUE)
dir.create('results/salmon_deseq2_results', showWarnings = FALSE, recursive = TRUE)

# Load sample information

samples=data.frame(samples=col_concat(str_split_fixed(list.files("salmon"),"_",5)[,2:3], sep = "_"), condition=str_split_fixed(list.files("salmon"),"_",5)[,2])
row.names(samples)=samples[,1]

## Deseq2 workflow
files=file.path("salmon",list.files("salmon"),"quant.sf")
tx2gene=read.csv("reference/chr22_ucsc_grch38_refseq_txn2gene.tsv", sep = "\t",stringsAsFactors = F, header=F)

salmon_data <- tximport(files, type="salmon", tx2gene=tx2gene)

ddsTxi <- DESeqDataSetFromTximport(salmon_data,
                                   colData = samples ,
                                   design = ~ condition)
counts(ddsTxi)

## Filter transcripts with less than 10 counts
keep <- rowSums(counts(ddsTxi)) >= 10
dds <- ddsTxi[keep,]
dds
# To be sure, make normal as reference condition
dds$condition <- relevel(dds$condition, ref = "normal")
dds
# DESeq on DESeq2 object
ddds <- DESeq(dds)

# Extract results for comparison
res <- results(ddds, coef="condition_tumor_vs_normal")

# sort the results
resOrdered <- res[order(res$padj),]

## Write results to Hard disk
write.csv(as.data.frame(resOrdered),file="results/salmon_deseq2_results/condition_treated_results.csv")

# Shrink the log values
reslfc=lfcShrink(ddds, coef="condition_tumor_vs_normal", type="apeglm")

# store the pics in pdf
pdf(file = "results/salmon_deseq2_results/salmon_deseq2_results.pdf")

# Plot counts for gene with lowest fold change (down regulated gene)
plotCounts(ddds, gene=which.min(res$log2FoldChange), intgroup="condition")

# Plot counts for gene with lowest adjusted p-value (statistically significant gene)
plotCounts(ddds, gene=which.min(res$padj), intgroup="condition")

# PCA for samples
plotPCA(rlog(ddds), intgroup="condition")+theme_bw()

# Distance plot for samples
sampleDists <- as.matrix(dist(t(assay(rlog(ddds)))))
cols=colorRampPalette( c("green","yellow","red"))(255)
pheatmap(sampleDists, col=cols)

##  Expression heatmap
select=row.names(res[order(-res$log2FoldChange),])[1:20]
cols=colorRampPalette( c("green","yellow","red"))(255)
pheatmap(assay(rlog(ddds))[select,], col=cols)

#Plot data post transformation (rlog)
meanSdPlot(assay(rlog(ddds)))

# Maplot for res
plotMA(res)

# Close the graphics device
dev.off()

# Generate report in pdf

report <- DESeq2Report(ddds, project = 'Salmon-DESEQ2 workflow',
    intgroup = c('condition'), outdir = 'results/salmon_deseq2_results',
    output = 'index', theme = theme_bw(), browse = F,device = "pdf", output_format = 'pdf_document')

## Generate report in html

report <- DESeq2Report(ddds, project = 'Salmon-DESEQ2 workflow',
   intgroup = c('condition'), outdir = 'results/salmon_deseq2_results',
   output = 'index', theme = theme_bw(), browse = F)


## Save the workspace

save.image("results/salmon_deseq2_results/salmon_results.Rdata")

## Load the workspace

# load("results/salmon_deseq2_results/salmon_results.Rdata")


## Wasabi and Sleuth workflow
# dir.create("results/sleuth_results")
# # Wasabi workflow
# sfdirs <- file.path("salmon", c(list.files("salmon")))
# prepare_fish_for_sleuth(sfdirs)

## Preparation for sleuth
# sfdata=data.frame(sample=list.files("salmon"), path=sfdirs, condition=samples$condition, stringsAsFactors = F)
# design = ~condition
# names(tx2gene)=c("target_id","HGNC")
# so <- sleuth_prep(sfdata, design, target_mapping = tx2gene,num_cores = 1)
#
# # Sleuth fit
# so <- sleuth_fit(so)
#
# # Extract  expression data
# oe <- sleuth_wt(so, 'conditiontumor')
#
# # Sleuth results as data frame
# sleuth_results_oe=sleuth_results(oe, 'conditiontumor', show_all = TRUE)
#
#
# # Remove rows with no
# sloe=sleuth_results_oe[complete.cases(sleuth_results_oe),]
# write.csv(sloe, "results/sleuth_results/sleuth_expression_results.txt", sep="\t")
#
# # Merge gene names from tx2gene object and order by qvalue
# mer_sloe=merge(sloe, tx2gene, all.x=T)
# mer_sloe[order(mer_sloe$qval),]
#
# # Write the results to hard disk
# write.csv(sloe, "results/sleuth_results/sleuth_expression_results_merged.txt", sep="\t")
#
# # Save the workflow to HDD
# save.image("results/sleuth_results/sleuth_results.Rdata")