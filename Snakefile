shell.executable("bash")
import shutil

configfile: "config.yaml"

## Don't use workdir as variable. It is snakemake hardcoded working directory
workdir: "/home/suresh/Desktop/salmon_analysis"
data_dir = "/home/suresh/Desktop/salmon_analysis"

# print(glob_wildcards(data_dir + "raw_data/{type}_{sample}_rep{rep}_r{len}.fastq.gz"))
(types,samples,reps,lens)=glob_wildcards( "raw_data/{type}_{sample}_rep{rep}_r{len}.fastq.gz")

types=sorted(list(set(types)))
samples=sorted(list(set(samples)))
reps=sorted(list(set(reps)))
lens=sorted(list(set(lens)))

#print (expand ('hcc1395_{sample}_rep{rep}_r{len}.fastq.gz', sample=samples, rep=reps, len=lens))

rule all:
	input:
		expand("reference_index"),
		expand("reference_index/hash.bin"),
		expand("fastqc/{type}_{sample}_rep{rep}_r{len}_fastqc.zip",type=types,sample=samples, rep=reps, len=lens),
		expand("cutadapt/{type}_{sample}_rep{rep}_cutadapt_r{len}.fastq.gz",type=types,sample=samples, rep=reps, len=lens),
		expand("cutadapt/{type}_{sample}_rep{rep}_cutadapt_r{len}_fastqc.zip", type=types,sample=samples, rep=reps, len=lens),
		expand("salmon/{type}_{sample}_rep{rep}_cutadapt_salmon_quant",type=types,sample=samples, rep=reps),
		expand('results/salmon_deseq2_results/salmon_results.Rdata')

onsuccess:
	shutil.rmtree(".snakemake")

rule clean:
	shell: "rm -rf .snakemake/"

include: 'rules/index.smk'
include: 'rules/fastqc.smk'
include: 'rules/cutadapt.smk'
include: 'rules/fastqc_after.smk'
include: 'rules/salmon_quant.smk'
include: 'rules/deseq.smk'