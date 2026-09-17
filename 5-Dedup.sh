# Deduplicate aligned reads: mark PCR/optical duplicates so that
# downstream analyses (variant calling, coverage) treat each fragment as
# an independent observation.

#   collate  -> group reads by name so mates are adjacent (required by fixmate)
#   fixmate -m -> add mate coordinate + ms/MC tags that markdup needs
#   sort     -> return to coordinate order
#   markdup -s -> flag/remove duplicates; -s prints duplicate-rate stats
#   index    -> index final BAM for random-access tools

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

#*** dedup.bam file sill contains duplicate reads they are just flagged now. 
#*** Freebayes, samtools and gatk ignore duplicate flagged reads by default
#*** add -r flag to samtools markdup to remove if necessary for smaller files