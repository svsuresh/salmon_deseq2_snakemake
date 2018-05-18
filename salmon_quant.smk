rule salmon_quant:
	input:
		R1 = rules.cutadapt.output.R1,
		R2 = rules.cutadapt.output.R2,
		index=rules.index.output.directory
	output:
		B1 = "salmon/{type}_{sample}_rep{rep}_cutadapt_salmon_quant"
	version:
		shell("salmon --version")
	log:
		'logs/salmon/{type}_{sample}_rep{rep}.salmon.log'
	message:
		"..wait...aligning and quantifying sequence files....."
	priority: 85
	threads: 4
	shell:"""
		salmon quant -i {input.index} -l A  -1 {input.R1} -2 {input.R2} -o {output.B1} -q --useVBOpt --gcBias --seqBias --posBias -p {threads} --numBootstraps 30 &> {log}
	"""
