rule multiqc:
	output: 
		"results/multiqc/project A.html"
	version:
		shell ("multiqc --version")
	priority: 80
	log: "results/log/multiqc"
	shell:"""
		multiqc results -s -i "Project A results" -n "project A"  -b "Salmon-DESEQ2/WASABI-SLEUTH results" -o results/multiqc -ip -q --no-data-dir &> {log} 
	"""
