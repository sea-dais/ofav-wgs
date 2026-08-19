conda activate bcftools

# what does site depth look like ?
bcftools query -f '%INFO/DP\n' vcf/7x11_family.vcf | \
  sort -n | awk '{a[NR]=$1} END{print "min",a[1]; print "median",a[int(NR/2)]; print "max",a[NR]}'

# Stage 1: biallelic SNPs (structural — same at any depth)
bcftools norm -f $GENOME_FASTA -m -any vcf/7x11_family.vcf \
  | bcftools view -m2 -M2 -v snps -Oz -o vcf/7x11_biallelic.vcf.gz
bcftools index vcf/7x11_biallelic.vcf.gz
bcftools view -H vcf/7x11_biallelic.vcf.gz | wc -l

# Stage 2 (TEST): loose thresholds so sites survive shallow data
bcftools view vcf/7x11_biallelic.vcf.gz \
  -e 'QUAL<20 || INFO/DP<8 || F_MISSING>0.5' \
  -Oz -o vcf/7x11_filtered.vcf.gz
bcftools index vcf/7x11_filtered.vcf.gz
bcftools view -H vcf/7x11_filtered.vcf.gz | wc -l