# GWAS project
--------------

Starting from A-Z

Download the raw read FASTQ files from server.

    In DBSSE, the practise there is sequence one sample in 2 different lane. Therefore we need to concatenate the 2 FASTQ files together. e.g. the pair-end reads.

	cat A.R1.fq.gz B.R1.fq.gz > R1.fq.gz
	cat A.R2.fq.gz B.R2.fq.gz > R2.fq.gz


#trim ends or adapters using trimmomatic-0.39.jar

	java -jar trimmomatic-0.39.jar PE -threads 16 -trimlog logfile R1.fq.gz R2.fq.gz R1_paired.fq.gz R1_unpaired.fq.gz R2_paired.fq.gz R2_unpaired.fq.gz ILLUMINACLIP:adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:36

#check the output of trimmed files with fastQC:

	fastqc -o {directory for outputs} -t 6 --noextract input.fq.gz




Learning Markdown, to insert a block of code, indent it by 4 spaces:

    import os
    import sys
    print("my first markdown block of code")
    
With Markdown, I can edit text and style it.
