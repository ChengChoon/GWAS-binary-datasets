# GWAS project
--------------

Starting from A-Z

Download the raw read FASTQ files from server.

    In DBSSE server in SCICORE: "/scicore/projects/openbis/userstore/duw_ebert/", the practise there is sequence one sample in 2 different lane. Therefore we need to concatenate the 2 FASTQ files together. e.g. the pair-end reads below:
	cat A.R1.fq.gz B.R1.fq.gz > R1.fq.gz
	cat A.R2.fq.gz B.R2.fq.gz > R2.fq.gz

Trim ends or adapters using trimmomatic-0.39.jar

	java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 10 -trimlog ${1}_logfile ${1}_R1.fastq.gz ${1}_R2.fastq.gz ${1}_R1_paired.fq.gz ${1}_R1_unpaired.fq.gz ${1}_R2_paired.fq.gz ${1}_R2_unpaired.fq.gz ILLUMINACLIP:adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:36

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

	R script = R_loop_cov.R 

Run Picard to mark & remove duplicated reads

	java -Xmx32G -XX:ParallelGCThreads=16 -jar picard.jar MarkDuplicates I=R.sorted.bam O=R.sorted.MD.bam M=R.sorted.MD.bam.metrics.txt OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 CREATE_INDEX=true TMP_DIR={create your own directory for temporary files} REMOVE_DUPLICATES=true





