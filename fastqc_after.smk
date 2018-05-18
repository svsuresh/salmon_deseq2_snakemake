rule fastqc_after:
	input:
		"cutadapt/{type}_{sample}_rep{rep}_cutadapt_r{len}.fastq.gz"
	output:
		"cutadapt/{type}_{sample}_rep{rep}_cutadapt_r{len}_fastqc.zip"
	version:
		shell("fastqc --version")
	log:
		'logs/fq_after/{type}_{sample}_rep{rep}_r{len}.fastqc.log'
	priority: 90
	threads: 4
	message: "....Checking the quality..wait please..."
	shell:"""
	fastqc -t {threads} {input} -q -f fastq -o cutadapt/ &> {log}
	"""
