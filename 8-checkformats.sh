export FILE="vcf/7x11_filtered.vcf.gz"
# What FORMAT fields exist, and is AD one of them?
bcftools view -h $FILE | grep '##FORMAT'

# Pull AD for a pool sample at the first handful of sites
bcftools query -s P1-7x11-PL \
  -f '%CHROM\t%POS\t[%GT\t%AD]\n' $FILE | head -20

# sites where the pool has real alt AND ref reads (intermediate freq), with QUAL
bcftools query -s P1-7x11-PL \
  -f '%CHROM\t%POS\t%QUAL\t[%GT\t%AD]\n' $FILE \
  | awk -F'\t' '{split($5,a,","); if(a[1]>=2 && a[2]>=2) print}' | head -20