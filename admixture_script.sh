
#!/bin/bash

while (( run < 5 )); do  ## we usually run 100 runs for each K for accuracy of the final results
run=$(( run + 1 ));
for K in 2 3 4 5  ; do  # select a meaningful series of K - the more Ks, the longer the run obviously
./admixture -s time --cv ../73C_BISNP_filter_exclude_filtered_beagle_name_plink.bed $K -j12 | tee log.K${K}.RUN$run.out;
mv 73C_BISNP_filter_exclude_filtered_beagle_name_plink.$K.P K$K.Run$run.P;
mv 73C_BISNP_filter_exclude_filtered_beagle_name_plink.$K.Q K$K.Run$run.Q;
done;
done



