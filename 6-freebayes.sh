conda create -n freebayes2 -c bioconda -c conda-forge freebayes vcflib parallel
conda activate freebayes2

# 1. the genome index (.fai) — freebayes-parallel needs it to make regions
ls ${SCRATCH}/OfavGenome/GCF_002042975.1_ofav_dov_v1_genomic.fna.fai
# if missing:  samtools faidx $GENOME_FASTA

# 2. the helper scripts that ship with freebayes
which freebayes-parallel
which fasta_generate_regions.py
###### /work/08717/dmflores/ls6/software/envs/freebayes/bin/fasta_generate_regions.py

# 3. GNU parallel (freebayes-parallel depends on it)

##### conda install conda-forge::parallel
which parallel

export GENOME_FASTA=$SCRATCH/OfavGenome/GCF_002042975.1_ofav_dov_v1_genomic.fna
# make region chunks (100kb each) from the .fai
awk '{for(i=1;i<=$2;i+=100000) print $1":"i"-"(i+100000<$2 ? i+100000 : $2)}' \
  ${GENOME_FASTA}.fai > regions.txt
head regions.txt
wc -l regions.txt      # should be a lot of lines given 1,933 scaffolds


########################
export GENOME_FASTA=$SCRATCH/OfavGenome/GCF_002042975.1_ofav_dov_v1_genomic.fna

mkdir -p vcf
>fbp
echo "freebayes-parallel regions.txt 24 -f $GENOME_FASTA \
dedup/11-AD.dedup.bam dedup/7-AD.dedup.bam \
dedup/2-7x11-LV.dedup.bam dedup/3-7x11-LV.dedup.bam \
dedup/P1-7x11-PL.dedup.bam dedup/P2-7x11-PL.dedup.bam dedup/P3-7x11-PL.dedup.bam \
dedup/a7-SP.dedup.bam dedup/b7-SP.dedup.bam \
dedup/e11-SP.dedup.bam dedup/f11-SP.dedup.bam dedup/g11-SP.dedup.bam \
> vcf/7x11_family.vcf" >> fbp

ls6_launcher_creator.py -j fbp -n fbp \
            -t 02:00:00 -e dmflores@utexas.edu \
            -q development -A IBN21018
sbatch fbp.slurm

# Check 
bcftools view -h vcf/7x11_family.vcf | tail -1     # header line — should show all 12 sample columns
grep -vc '^#' vcf/7x11_family.vcf                   # count of variant sites

ls -lh vcf/7x11_family.vcf          # size — is it 0 bytes, tiny, or substantial?
head -50 vcf/7x11_family.vcf        # what's actually at the top?