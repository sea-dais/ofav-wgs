mkdir -p bams
>addrg
for file in mapped/*.sam; do
sample=$(basename "$file" .sam)
echo "samtools addreplacerg -r ID:${sample} -r SM:${sample} -r PL:ILLUMINA -o - $file | samtools sort -@ 8 -o bams/${sample}.sorted.bam - && samtools index bams/${sample}.sorted.bam" >> addrg
done

ls6_launcher_creator.py -j addrg -n addrg -t 01:00:00 -e dmflores@utexas.edu -q gpu-a100-dev -A IBN21018
sbatch addrg.slurm

# 1. all BAMs present and indexed?
ls bams/*.sorted.bam | wc -l          # number of samples 
ls bams/*.sorted.bam.bai | wc -l      # same count

# 2. read groups actually stamped, with correct sample names?
samtools view -H bams/11-AD.sorted.bam | grep '^@RG'
samtools view -H bams/P1-7x11-PL.sorted.bam | grep '^@RG'


     