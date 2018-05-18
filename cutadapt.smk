rule cutadapt:
	input: 
		R1 = "raw_data/{type}_{sample}_rep{rep}_r1.fastq.gz",
		R2 = "raw_data/{type}_{sample}_rep{rep}_r2.fastq.gz"
	output:
		R1 = "cutadapt/{type}_{sample}_rep{rep}_cutadapt_r1.fastq.gz",
		R2 = "cutadapt/{type}_{sample}_rep{rep}_cutadapt_r2.fastq.gz"	
	version:
		shell("cutadapt --version")
	log: 
		'logs/cutadapt/{type}_{sample}_rep{rep}.cutadapt.log'
	message:
		"..wait...cutting sequence files....."
	priority:95
	threads:4
	shell:"""
		cutadapt --quiet -j {threads} -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT  -o  {output.R1}  -p {output.R2}  {input.R1} {input.R2}  &> {log}  
	"""