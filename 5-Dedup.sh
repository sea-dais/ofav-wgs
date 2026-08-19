mkdir -p dedup

>dedup_job
for file in bams/*.sorted.bam; do
sample=$(basename "$file" .sorted.bam)
echo "samtools collate -@ 8 -O $file | samtools fixmate -m -@ 8 - - | samtools sort -@ 8 - | samtools markdup -s -@ 8 - dedup/${sample}.dedup.bam && samtools index dedup/${sample}.dedup.bam" >> dedup_job
done

ls6_launcher_creator.py -j dedup_job -n dedup_job \
            -t 01:00:00 -e dmflores@utexas.edu \
            -q development -A IBN21018
sbatch dedup_job.slurm