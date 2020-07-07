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

Run GATK HaplotypeCaller to create intermediate GVCF, which can then be used in GenotypeGVCFs for joint genotyping of multiple samples. 

	java -jar gatk.jar HaplotypeCaller -R ref.fasta -I R.sorted.RG.MD.bam -O R.sorted.RG.MD.g.vcf -ERC GVCF 

To consolidate gvcf files, we can use GenomicsDBImport or CombineGVCFs. GenomicsDBImport is much recommended. 
The main advantage of using CombineGVCFs over GenomicsDBImport is the ability to combine multiple intervals at once without building a GenomicsDB. 
CombineGVCFs is slower than GenomicsDBImport though, so it is recommended CombineGVCFs only be used when there are few samples to merge.
The caveat of GenomicsDBImport is at least one interval must be provided, unless incrementally importing new samples in which case specified intervals are ignored in favor of intervals specified in the existing workspace. 
So I create a BED file generated form reference genome for a complete whole genome interval list.
BED format, where intervals are in the form <chr> <start> <stop>, with fields separated by tabs.

	samples=$(find . | sed 's/.\///' | grep -E 'g.vcf$' | sed 's/^/--variant /') # place sample paths into variable
	gatk --java-options "-Xmx36G" CombineGVCFs \
       $(echo $samples) \
       -O path/to/combined.vcf \
       -R path/to/ref.fa

	samtools faidx ref.fna # make .fai file 
	awk '{print $1 "\t0\t" $2}' ref.fna.fai > ref.fna.bed # make .bed file

	samples=$(find . | sed 's/.\///' | grep -E 'g.vcf$' | sed 's/^/--variant /') # place sample paths into variable
	gatk --java-options "-Xmx36G" GenomicsDBImport \
          $(echo $samples)\
          --genomicsdb-workspace-path my_database \
          --intervals path/to/ref.fna.bed

 	gatk --java-options "-Xmx36G" GenotypeGVCFs \
           -R path/to/ref.fna \
           -V gendb://path/to/my_database OR -V path/to/combined.vcf \
           -O path/to/genotypes.vcf

	The number of variants generated by GenomicsDBImport or CombineGVCFs are same. However, GenomicsDBImport used as twice much time with CombineGVCFs. So I will keep using CombineGVCFs for now.

run GATK SelectVariants to only work with biallelic SNPs

	gatk SelectVariants -R ref.fasta -V input.vcf.gz -select-type SNP --restrict-alleles-to BIALLELIC -O input_BISNP.vcf.gz

run GATK VariantFiltration to follow the basic hard-filter setting. I also included genotypes filter to remove GQ < 20. I run --missing-values-evaluate-as-failing in which missing values will be considered failing the expression and subsequently filtered. I also set filtered genotypes to no-call (./.).

	gatk VariantFiltration -R ref.fasta -V input_BISNP.vcf.gz -filter "QD < 2.0" --filter-name "QD2" -filter "QUAL < 30.0" --filter-name "QUAL30" -filter "SOR > 3.0" --filter-name "SOR3" -filter "FS > 60.0" --filter-name "FS60" -filter "MQ < 40.0" --filter-name "MQ40" -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" -G-filter "GQ < 20.0" -G-filter-name "GQ20" --set-filtered-genotype-to-no-call --missing-values-evaluate-as-failing -O input_BISNP_filter.vcf.gz

run GATK SelectVariants again to exclude all filtered sites. I also set filtered genotypes to no-call (./.). 

	gatk SelectVariants -R ref.fasta -V input_BISNP_filter.vcf.gz --set-filtered-gt-to-nocall --exclude-filtered -O input_SNP_filter_exclude.vcf.gz

To compare all the vcf files if the filtering process is working or not, I choose VT program. 

	 #this will create a directory named vt in the directory you cloned the repository
	 1. git clone https://github.com/atks/vt.git  

 	#change directory to vt
 	2. cd vt 

 	#run make, note that compilers need to support the c++0x standard 
 	3. make 

 	#you can test the build
 	4. make test

Remove line started with "##"

	zgrep -v "^##" input.vcf.gz > out.vcf

After all the filtering, we wanna check the output from the filtering steps. The first to look at column 7 = "FILTER" in which all SNPs should have "PASS".

	awk '{print $7}' input_SNP_filter_exclude_nohead.vcf.gz | sort | uniq > filter_flag_uniq_input

Next, we check column 8 = "INFO" contained the information related to hard-filtering that we applied.

	AC AF AN BaseQRankSum DP ExcessHet FS InbreedingCoeff MLEAC MLEAF MQ MQRankSum QD ReadPosRankSum SOR

I used a script (forplot_INFO.sh) to generate the input file for plotting in Rscript (input_INFO.R).

Next I looked at sample or genotype level filters. At column 9 = "FORMAT" will describe what are the information format: {GT:AD:DP:FT:GQ:PL} and the following columns will be the sample representatives. For more info about the format means, check the link below:
 
	https://gatk.broadinstitute.org/hc/en-us/articles/360035531692-VCF-Variant-Call-Format

I have a python script check_AD.py to look at the AD field with your threshold value.

To QC on the sample quality, I run vcftools to check the number of missing sites per samples and generate output=out.imiss. Let's examine the "F_MISS" and plot a histogram on it.

        vcftools --vcf input.vcf --missing-indv

To filter the SNPs on the genotype value, I applied a genotype call rate (90%) across all individuals to allow maximum 10 % of missing genotypes prior to imputation as suggested by Marchini & Howie (2010) for better prediction of genotype at 2 to 3 % error rate.

	vcftools --vcf input.vcf --max-missing 0.90 --maf 0.05 --recode --recode-INFO-all --out

Impute missing genotypes with beagle

	java -jar beagle.18May20.d20.jar gt=input.vcf.gz out=out.vcf.gz

Remove scaffold from the naming because plink don't take character indexing

	zcat input.vcf.gz | sed -e 's/F|quiver//g' > output.vcf

Generate plink files from vcf, which you can then use as an input file for gemma

	./plink2 --vcf input.vcf --make-bed --out out_plink --allow-extra-chr

Population stratification using --pca from plink. Two output files: Eigenvectors and eigenvalues. Change the top row or header in Eigenvectors with eigenvalues.

	./plink2 --bfile 73C_BISNP_filter_exclude_filtered_beagle_name_plink --pca --out OUT --allow-extra-chr

Use genesis (git clone https://github.com/shaze/genesis) for Population structure and PCA viewer. The Genesis.jar file which requires Java 1.7 or 1.8. Run the program in Mac machine:

	java -XstartOnFirstThread -jar Genesis.jar

And like this on Windows/Linux

	java -jar Genesis.jar

