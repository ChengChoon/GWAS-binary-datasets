#!/bin/bash

all="000016 000022 000000 000046 000011 000026 000028 000074 000077 000001 000098 000012 000018 000038 000015 000050 000005 000031 000014 000042 000029 000066 000006 000136"

for val in $all
do

  command="awk '\$1==\"$val\"' 51C_BISNP_filter_exclude_beagle_plink_lmm.assoc.txt | sort -r -k 3,3 -n > ${val}_reverse"
  echo $command
  eval "$command"
done
