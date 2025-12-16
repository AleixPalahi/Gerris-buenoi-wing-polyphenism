#!/bin/bash -l
#SBATCH -A snic2021-5-195
#SBATCH -o star_mapping_p5_softmasked_lib_%j.out
#SBATCH -J star_mapping_p5_softmasked_lib
#SBATCH -p core -c 10
#SBATCH -t 1-00:00:00
#SBATCH --mail-user=douglas.scofield@ebc.uu.se
#SBATCH --mail-type=ALL

sampleprefix=$1


projectdir=/proj/snic2019-35-58/water_strider/RNA-seq_wing_bud

readsdir=$projectdir/cutadapt_trimmed_reads

r1=$readsdir/${sampleprefix}.R1.trimmed.fastq.gz
r2=$readsdir/${sampleprefix}.R2.trimmed.fastq.gz

[[ -f $r1 && -f $r2 ]] || { echo "either '$r1' or '$r2' do not exist"; exit 1; }


reference=/proj/snic2019-35-58/water_strider/final_files/indices/GenomeDir-star-2.7.9a


threads=${SLURM_NTASKS:-10}

module load bioinfo-tools
module load star/2.7.9a

mkdir ${sampleprefix}
cd ${sampleprefix}

STAR --genomeDir $reference --readFilesIn $r1 $r2  --readFilesCommand zcat --runThreadN $threads --twopassMode Basic --outSAMtype BAM SortedByCoordinate --outWigType wiggle --outWigStrand Stranded --outWigNorm RPM --quantMode GeneCounts

chmod -R u+rwX,g+rwX,o+rX .



