#!/bin/bash

# Impute missing genotypes with beagle
java -Xmx80G -jar beagle.27Jan18.7e1.jar gt=YESPASS.vcf.gz out=YESPASS_beagle

# Remove 7. line from the vcf file (otherwise you can’t produce a plink file)
zcat YESPASS_beagle.vcf.gz | sed 7d > YESPASS_beagle_w7.vcf

# Compressed the file 
bgzip YESPASS_beagle_w7.vcf

# Remove scaffold from the naming because plink don't take charcter indexing
zcat YESPASS_beagle_w7.vcf.gz | sed -e 's/scaffold//g' > YESPASS_beagle_w7_noscaffold.vcf

# Compressed the file
bgzip YESPASS_beagle_w7_noscaffold.vcf

# Generate a plink file with vcftools
vcftools --gzvcf YESPASS_beagle_w7_noscaffold.vcf.gz --plink --out YESPASS_beagle_w7_noscaffold_plink

# Generate a bfile with plink, which you can then use as an impute file for gemma
./software/plink --noweb --file YESPASS_beagle_w7_noscaffold_plink --out YESPASS_beagle_w7_noscaffold_plink --make-bed
