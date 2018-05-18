rule deseq2:
    output: 
    	'results/salmon_deseq2_results/salmon_results.Rdata'
    version: shell("R --version")
    priority: 80
    script:
        '../scripts/salmon_deseq2.R'
