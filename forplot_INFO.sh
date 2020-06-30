


awk '{print $8}' ${1} > ${1}_R8.txt

sed 's/\;/ /g' ${1}_R8.txt > ${1}_R8_sep.txt

sed -E 's/[[:alpha:]]+=([^ ]+)/\1/g' ${1}_R8_sep.txt | grep -v "INFO" > ${1}_header.txt

cat INFO_header.txt ${1}_header.txt > ${1}_forplot.txt


