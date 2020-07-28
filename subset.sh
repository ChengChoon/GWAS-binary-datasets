
gunzip {1}.vcf.gz

sed -e 's/F|quiver//g' -e 's/|quiver//g' {1}.vcf > {1}_name

./plink2 --vcf {1}_name --make-bed --allow-extra-chr --out {1}_name_plink

./plink --allow-extra-chr --bfile {1}_name_plink --geno 0.2 --make-bed --out {1}_name_plink_1

./plink --allow-extra-chr --bfile {1}_name_plink_1 --mind 0.2 --make-bed --out {1}_name_plink_2

./plink --allow-extra-chr --bfile {1}_name_plink_2 --geno 0.02 --make-bed --out {1}_name_plink_3

./plink --allow-extra-chr --bfile {1}_name_plink_3 --mind 0.02 --make-bed --out {1}_name_plink_4

./plink --allow-extra-chr --bfile {1}_name_plink_4 --maf 0.05 --make-bed --out {1}_name_plink_5

./plink --allow-extra-chr --bfile {1}_name_plink_5 --hwe 1e-6 --make-bed --out HapMap_hwe_filter_step1

./plink --allow-extra-chr --bfile HapMap_hwe_filter_step1 --hwe 1e-10 --hwe-all --make-bed --out {1}_name_plink_6

./plink --allow-extra-chr --allow-no-sex --bfile {1}_name_plink_6 --recode vcf-iid --out {1}_back

java -jar beagle.18May20.d20.jar gt={1}_back.vcf out={1}_beagle

./plink2 --allow-extra-chr --allow-no-sex --vcf {1}_beagle.vcf.gz --make-bed --out {1}_beagle_plink

