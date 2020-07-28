
cat 000016_reverse 000022_reverse 000096_forward 000032_forward 000037_forward 000157_forward 000040_forward 000045_forward 000010_forward 000047_forward 000008_forward > chr1

awk '{$16="1"; print $0}' chr1 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr1_all_N

cat 000036_forward 000004_forward 000007_forward 000093_forward 000000_reverse > chr2

awk '{$16="2"; print $0}' chr2 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr2_all_N

cat 000009_forward 000062_forward 000002_forward 000017_forward 000044_forward 000104_forward 000109_forward 000112_forward 000024_forward 000068_forward 000046_reverse 000115_forward > chr3

awk '{$16="3"; print $0}' chr3 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr3_all_N

cat 000011_reverse 000023_forward 000051_forward 000060_forward 000064_forward 000087_forward 000092_forward 000065_forward 000069_forward 000026_reverse 000225_forward 000028_reverse > chr4

awk '{$16="4"; print $0}' chr4 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr4_all_N

cat 000108_forward 000074_reverse 000077_reverse 000053_forward 000027_forward 000025_forward 000049_forward 000061_forward 000067_forward 000071_forward 000080_forward 000095_forward 000001_reverse > chr5

awk '{$16="5"; print $0}' chr5 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr5_all_N

cat 000052_forward 000076_forward 000201_forward 000082_forward 000058_forward 000073_forward 000098_reverse 000012_reverse 000019_forward 000021_forward > chr6

awk '{$16="6"; print $0}' chr6 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr6_all_N

cat 000018_reverse 000020_forward 000048_forward 000057_forward 000056_forward 000054_forward 000003_forward 000039_forward 000038_reverse > chr7

awk '{$16="7"; print $0}' chr7 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr7_all_N

cat 000015_reverse 000050_reverse 000005_reverse 000088_forward 000103_forward 000030_forward 000031_reverse 000063_forward 000163_forward > chr8

awk '{$16="8"; print $0}' chr8 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr8_all_N

cat 000014_reverse 000169_forward 000042_reverse 000029_reverse 000043_forward 000141_forward 612_forward 000070_forward 000081_forward 000083_forward 000089_forward 000097_forward 000102_forward 000111_forward 000113_forward 000114_forward 000116_forward 000123_forward 000128_forward 000209_forward 000227_forward 000075_forward 000059_forward 000107_forward 000079_forward 000066_reverse 000086_forward > chr9

awk '{$16="9"; print $0}' chr9 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr9_all_N

cat 000006_reverse 000072_forward 000117_forward 000154_forward 000078_forward 000055_forward 000034_forward 000013_forward 000136_reverse 000035_forward > chr10

awk '{$16="10"; print $0}' chr10 | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > chr10_all_N

##cat chr1_all_N chr2_all_N chr3_all_N chr4_all_N chr5_all_N chr6_all_N chr7_all_N chr8_all_N chr9_all_N chr10_all_N > ALL_N
### still need to manually change the $16 value because of character and string complication
### awk '{$16="$1"; print $0}' ${1} | gawk '$1=(FNR FS $1)' | sed 's/\s/\t/g' > "${1}"_all_N


