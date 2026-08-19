################################
####### QC OF RAW READS ########
################################

### Simple code to run fastqc for each file
mkdir fastqc

>quality
for file in files/*.fastq.gz; do
echo "fastqc -o ./fastqc $file" >>quality; done

ls6_launcher_creator.py -j quality -n quality -t 02:00:00 -e dmflores@utexas.edu -w 48 -N 1 -A IBN21018
sbatch quality.slurm

### View html files that are in the output directory
SOURCE='dmflores@ls6.tacc.utexas.edu:/scratch/08717/dmflores/ofav-wgs/fastqc'
scp "$SOURCE/*\.html" .
########## looking as expected from past sequenicng
########## mainly good, some poly G tail in the R2 sequences
#*#*#* Results from fastqc can be used to decide what to do in the trimming steps



###############################
####### TRIMMING STEPS ########
###############################
mkdir trimmed
>trimnew
for file in files/*R1_001.fastq.gz; do
base=$(basename "$file")
echo "cutadapt -q 20 -m 100 -e 0.2 -g file:forward.fasta -G file:forward.fasta -a file:reverse.fasta -A file:reverse.fasta --discard-untrimmed -o trimmed/${base/R1_001.fastq.gz/R1.trim.gz} -p trimmed/${base/R1_001.fastq.gz/R2.trim.gz} $file ${file/R1_001.fastq.gz/R2_001.fastq.gz}" >> trimnew; done

ls6_launcher_creator.py -j trimnew -n trimnew -t 01:00:00 -e dmflores@utexas.edu -w 48 -q gpu-a100-dev -A IBN21018
sbatch trimnew.slurm

########################
####### MAPPING ########
########################
idev -t 00:30:00 
# bowtie index genome 
export GENOME_FASTA=$SCRATCH/OfavGenome/GCF_002042975.1_ofav_dov_v1_genomic.fna
bowtie2-build $GENOME_FASTA $SCRATCH/OfavGenome/ofav_index

export GENOME_INDEX=$SCRATCH/OfavGenome/ofav_index

mkdir mapped
>map
for file in trimmed/*R1.trim.gz; do
base=$(basename "$file")
sample=${base/_S*/}
echo "bowtie2 -x $GENOME_INDEX -1 $file -2 ${file/R1.trim.gz/R2.trim.gz} -S mapped/${sample}.sam --un-conc-gz mapped/${sample}_unaligned.fastq.gz -p 16" >> map; done


ls6_launcher_creator.py -j map -n map -a IBN21018 -e dmflores@utexas.edu -t 02:00:00 -q development
sbatch map.slurm

# all of this is to assign read numbers and alignment rates to each samples
grep 'overall alignment rate' map.e3374625 > align_rates
grep 'reads; of these:' map.e3374625 > read_num


conda create -n seqkit -c bioconda -c conda-forge seqkit
conda activate seqkit

seqkit stats trimmed/*.trim.gz > trimreadcounts
seqkit stats files/*.fastq.gz trimmed/*.trim.gz > readcounts_compare


# TO CONTINUE
conda activate samtools 
samtools flagstat mapped/e11-SP.sam

# 1. how fragmented is the reference?
grep -c '^>' $SCRATCH/OfavGenome/*.fna

# 2. did poly-G actually survive trimming? (rules #1 in/out)
zcat trimmed/e11-SP_S26_L001_R2.trim.gz | head -20

# 3. are R1/R2 trimmed to equal read counts? (unequal = pairing problem)
seqkit stats trimmed/e11-SP_S26_L001_R1.trim.gz trimmed/e11-SP_S26_L001_R2.trim.gz