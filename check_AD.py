import gzip

thr = 20

f = gzip.open("73C_BISNP_filter_exclude.vcf.gz", "rt")
f2 = gzip.open("73C_BISNP_filter_exclude_filtered.vcf.gz", "wt")
f3 = gzip.open("73C_BISNP_filter_exclude_filtered_removed.vcf.gz", "wt")
r = f.readline()
while r:
    r = r.replace("\r", "").replace("\n", "").split("\t")
    if r[0].startswith("#"):
        f2.write("\t".join(r)+"\n")
        r = f.readline()
        continue
    if len(r)!=82:
        f2.write("\t".join(r)+"\n")
    else:
        valid = False
        for rec in r[9:]:
            rec2 = rec.split(":")
            rec3 = rec2[1].split(",")
            rec3 = [int(x) for x in rec3]
            rec4 = sum([x>=thr for x in rec3])
            if rec4>0:
                valid = True
                f2.write("\t".join(r)+"\n")
                break
        if not valid:
            f3.write("\t".join(r)+"\n")
    r = f.readline()
f.close()
f2.close()
f3.close()


