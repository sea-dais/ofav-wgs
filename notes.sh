bcftools stats -s - vcf/7x11_family.vcf.gz > stats_7x11.txt
grep '^PSC' stats_7x11.txt

Sample	Type	Avg depth
e11-SP	sperm	4.0
b7-SP	sperm	4.0
a7-SP	sperm	3.7
P2-7x11-PL	pool	17.6
f11-SP	sperm	3.8
3-7x11-LV	larva	4.5
P3-7x11-PL	pool	18.2
P1-7x11-PL	pool	19.2
2-7x11-LV	larva	3.5
7-AD	parent	3.8
11-AD	parent	3.4

samtools flagstat dedup_rg/2-7x11-LV.dedup.bam | grep -i duplicate
# 20.4M reads
# 9.2M reads after removing duplicates
# 74% mapping ==> 6.8M unique reads 
samtools flagstat dedup_rg/P1-7x11-PL.dedup.bam | grep -E 'total|duplicate|mapped'
# 111,244,662 reads
# 47,893,094 duplicates
# Duplicate rate: 47,893,094 / 111,244,662 = 43.1%


