All: Data Align Bcf Freebayes Multi Normalize

ACC=AF086833
SRR=SRR1553500
REF=ref/${ACC}.fa
BAM=${SRR}.bam
Data:
## Create reference directory
	mkdir -p ref
## Download reference
	conda run -n biostars efetch -db nuccore -format fasta -id ${ACC} | conda run -n biostars seqret -filter -sid ${ACC} > ${REF}
# Index reference for the aligner.
	bwa index ${REF}
# Index the reference genome for IGV
	samtools faidx ${REF}
# Get data from an Ebola sequencing run.
	conda run -n biostars fastq-dump -X 100000 --split-files ${SRR}

R1=${SRR}_1.fastq
R2=${SRR}_2.fastq
TAG="@RG\tID:${SRR}\tSM:${SRR}\tLB:${SRR}"
Align:
## Align and generate a BAM file.
	bwa mem -R ${TAG} ${REF} ${R1} ${R2} | samtools sort > ${BAM}
## Index the BAM file.
	samtools index ${BAM}

Bcf:
## Call variants with bcftools
	conda run -n biostars bcftools mpileup -Ov -f ${REF} ${BAM} | conda run -n biostars bcftools call --ploidy 1 -vm -Ov >  variants1.vcf

Freebayes:
## Call variants with FreeBayes
	conda run -n biostars freebayes -f ${REF} ${BAM} > variants2.vcf

SRR1=SRR1972917
SRR2=SRR1972918
SRR3=SRR1972919
SRR4=SRR1972920
TAG1="@RG\tID:${SRR1}\tSM:${SRR1}\tLB:${SRR1}"
TAG2="@RG\tID:${SRR2}\tSM:${SRR2}\tLB:${SRR2}"
TAG3="@RG\tID:${SRR3}\tSM:${SRR3}\tLB:${SRR3}"
TAG4="@RG\tID:${SRR4}\tSM:${SRR4}\tLB:${SRR4}"
R3=${SRR1}_1.fastq
R4=${SRR1}_2.fastq
R5=${SRR2}_1.fastq
R6=${SRR2}_2.fastq
R7=${SRR3}_1.fastq
R8=${SRR3}_1.fastq
R9=${SRR4}_1.fastq
R10=${SRR4}_1.fastq
BAM1=${SRR1}.bam
BAM2=${SRR2}.bam
BAM3=${SRR3}.bam
BAM4=${SRR4}.bam
Multi:
## Download fastq files
	conda run -n biostars fastq-dump -X 100000 --split-files ${SRR1}
	conda run -n biostars fastq-dump -X 100000 --split-files ${SRR2}
	conda run -n biostars fastq-dump -X 100000 --split-files ${SRR3}
	conda run -n biostars fastq-dump -X 100000 --split-files ${SRR4}
## Align and generate BAM files
	bwa mem -R ${TAG1} ${REF} ${R3} ${R4} | samtools sort > ${BAM1}
	bwa mem -R ${TAG2} ${REF} ${R5} ${R6} | samtools sort > ${BAM2}
	bwa mem -R ${TAG3} ${REF} ${R7} ${R8} | samtools sort > ${BAM3}
	bwa mem -R ${TAG4} ${REF} ${R9} ${R10} | samtools sort > ${BAM4}
## Produce multisample vcf
	conda run -n biostars bcftools mpileup -Ov -f ${REF} *.bam | conda run -n biostars bcftools call --ploidy 1 -vm -Ov >  variants.vcf

Normalize:
## Normalize all variant.vcf files
	conda run -n biostars bcftools norm -f ${REF} variants.vcf
	conda run -n biostars bcftools norm -f ${REF} variants1.vcf
	conda run -n biostars bcftools norm -f ${REF} variants2.vcf