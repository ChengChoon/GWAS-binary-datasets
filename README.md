GWAS project
--------------

Download the raw read FASTQ files from server.

	DBSSE server in SCICORE: "/scicore/projects/openbis/userstore/duw_ebert/", the practise is to concatenate the 2 FASTQ files from the same sample together because one sample is being sequence twice on different lanes. E.g. the pair-end reads below:
	
	cat A.R1.fq.gz B.R1.fq.gz > R1.fq.gz
	cat A.R2.fq.gz B.R2.fq.gz > R2.fq.gz

Trim ends or adapters using trimmomatic-0.39.jar

	java -jar trimmomatic-0.39.jar PE -threads 10 -trimlog ${1}_logfile ${1}_R1.fastq.gz ${1}_R2.fastq.gz ${1}_R1_paired.fq.gz ${1}_R1_unpaired.fq.gz ${1}_R2_paired.fq.gz ${1}_R2_unpaired.fq.gz ILLUMINACLIP:adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:36

Check the output of trimmed files with fastQC:

	fastqc -o {directory for outputs} -t 6 --noextract input.fq.gz

Mapping using bwa mem

	bwa mem -t 16 -M ref.fa R1_paired.fq.gz R2_paired.fq.gz > R.sam

Convert file format for size reduction sam to bam

	samtools view -b -S -@ 16 R.sam > R.bam

Certain program required sorted bam file for the following steps

	samtools sort R.bam -o R.sorted.bam -@ 16

Create index for Picard to run

	samtools index R.sorted.bam -@ 16

Run Bedtools to check the overal genomic coverage of the reads

	bedtools genomecov -ibam ${1} > ${1}.coverage.hist.txt
	using Rscript = R_loop_cov.R to generate the plot

Run Picard to add read group into the bam files. Because GATK required read group information for downstream analysis

	From the first line of FASTQ file, I can retrieve the read group information.
	
	zcat CH_H_2015_48_R1_paired.fq.gz | head -n 1

	@A00730:130:HJNTHDRXX:1:1101:1380:1031 1:N:0:GTAACATC+NAGCGATT

	@(instrument id):(run number):(flowcell ID):(lane):(tile):(x_pos):(y_pos) (read):(is filtered):(control number):(index sequence)
	FLOWCELL_BARCODE = @(instrument id):(run number):(flowcell ID)
	RGLB = <filename>_(index sequence)
	RGSM = <filename>
	RGPU = (instrument id):(run number):(flowcell ID):(lane):(index sequence)
	RGPL = ILLUMINA
	
	java -jar picard.jar AddOrReplaceReadGroups \
      	I=R.sorted.bam \
      	O=R.sorted_RG.bam \
     	RGLB= \
	RGPL= \
	RGPU= \
	RGSM=

Run Picard to mark & remove duplicated reads

	java -Xmx32G -XX:ParallelGCThreads=16 -jar picard.jar MarkDuplicates I=R.sorted.bam O=R.sorted.MD.bam M=R.sorted.MD.bam.metrics.txt OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 CREATE_INDEX=true TMP_DIR={create your own directory for temporary files} REMOVE_DUPLICATES=true





