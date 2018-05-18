rule fastqc:
	input:
		"raw_data/{type}_{sample}_rep{rep}_r{len}.fastq.gz"
	output:
		"fastqc/{type}_{sample}_rep{rep}_r{len}_fastqc.zip"
	version:
		shell("fastqc --version")
	log:
		'logs/fq_before/{type}_{sample}_rep{rep}_r{len}.fastqc.log'
	priority: 100
	threads: 4
	message: "....Checking the quality..wait please..."
	shell:"""
	fastqc -t {threads} {input} -q -f fastq -o fastqc/ &> {log}
	"""
