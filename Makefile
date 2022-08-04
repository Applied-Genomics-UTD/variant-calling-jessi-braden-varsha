All: Data Bcf

REF=refs/${ACC}.fa
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

BAM=align.bam
R1=simulated.bwa.read1.fastq.gz
R2=simulated.bwa.read2.fastq.gz
Bcf:
## Generate alignment
	bwa mem ${REF} ${R1} ${R2} | samtools sort > ${BAM}
## Index BAM file
	samtools index ${BAM}
## Compute genotypes
	conda run -n biostars bcftools mpileup -Ov -f ${REF} ${BAM} > genotypes.vcf
## Call variants
	conda run -n biostars bcftools call -vc -Ov genotypes.vcf > observed-mutations.vcf