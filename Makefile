All: Data

REF=refs/${ACC}.fa
BAM=align.BAM
ACC=AF086833
Data:
## Create reference directory
	mkdir -p refs
## Download reference genome
	conda run -n biostars efetch -db nuccore -format fasta -id ${ACC} > ${REF}
## Create bwa index
	bwa index ${REF}
## Create samtools index for reference
	samtools faidx ${REF}
## Simulate reads from reference
	conda run -n vc dwgsim ${REF} simulated