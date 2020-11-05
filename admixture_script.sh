#!/bin/bash

while (( run < 5 )); do  ### 5 is the default runs. To increase the accuracyof final result, we can run up to 100 runs for each K
run=$(( run + 1 ));
for K in 2 3 4 5  ; do  ### select a meaningful series of K. The more Ks, the longer the run it takes
./admixture -s time --cv input.bed $K -j12 | tee log.K${K}.RUN$run.out;
mv input.$K.P K$K.Run$run.P;
mv input.$K.Q K$K.Run$run.Q;
done;
done
