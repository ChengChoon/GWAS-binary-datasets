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
	
	zcat R.fq.gz | head -n 1

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

	java -jar picard.jar MarkDuplicates I=R.sorted.bam O=R.sorted.MD.bam M=R.sorted.MD.bam.metrics.txt OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 CREATE_INDEX=true TMP_DIR={create your own directory for temporary files} REMOVE_DUPLICATES=true

Run GATK HaplotypeCaller to create intermediate GVCF (not to be used in final analysis), which can then be used in GenotypeGVCFs for joint genotyping of multiple samples in a very efficient way 

	java -jar -Xmx64G gatk.jar HaplotypeCaller -R ref.fasta -I R.sorted.RG.MD.bam -O R.sorted.RG.MD.g.vcf -ERC GVCF 

To consolidate gvcf files, we can use GenomicsDBImport or CombineGVCFs. GenomicsDBImport is much recommended. The main advantage of using CombineGVCFs over GenomicsDBImport is the ability to combine multiple intervals at once without building a GenomicsDB. CombineGVCFs is slower than GenomicsDBImport though, so it is recommended CombineGVCFs only be used when there are few samples to merge.

	The caveat of GenomicsDBImport is at least one interval must be provided, unless incrementally importing new samples in which case specified intervals are ignored in favor of intervals specified in the existing workspace. So I create a BED file generated form reference genome for a complete who;e genome interval list.

	BED format, where intervals are in the form <chr> <start> <stop>, with fields separated by tabs.

	samples=$(find . | sed 's/.\///' | grep -E 'g.vcf$' | sed 's/^/--variant /') # place sample paths into variable
	path/to/gatk --java-options "-Xmx36G" CombineGVCFs \
       $(echo $samples) \
       -O path/to/combined.vcf \
       -R path/to/ref.fa

	samtools faidx ref.fna # make .fai file 
	awk '{print $1 "\t0\t" $2}' ref.fna.fai > ref.fna.bed # make .bed file

	samples=$(find . | sed 's/.\///' | grep -E 'g.vcf$' | sed 's/^/--variant /') # place sample paths into variable
	path/to/gatk --java-options "-Xmx36G" GenomicsDBImport \
          $(echo $samples)\
          --genomicsdb-workspace-path my_database \
          --intervals path/to/ref.fna.bed

 	path/to/gatk --java-options "-Xmx36G" GenotypeGVCFs \
           -R path/to/ref.fna \
           -V gendb://path/to/my_database OR -V path/to/combined.vcf \
           -O path/to/genotypes.vcf


