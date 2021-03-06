rule index:
	input: config["fa"]
	output:
		directory="reference_index",
		index="reference_index/hash.bin"
	version: shell("salmon --version")
	log: 'results/logs/salmon/salmon_index.log'
	priority:100
	threads: 4
	message: "....Indexing..wait please... "
	shell:"""
		salmon index -p {threads} -t {input} -i {output.directory} --type quasi -k 31 &> {log}
	"""
