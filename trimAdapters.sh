#!/bin/bash
#SBATCH -A staff
#SBATCH -p core
#SBATCH -c 10
#SBATCH -t 2:00:00
#SBATCH --mail-user douglas.scofield@ebc.uu.se
#SBATCH --mail-type=ALL

set -e

cutadapt="cutadapt"

Library=$1
Read1=(${Library}*R1*.fastq.gz)
Read2=(${Library}*R2*.fastq.gz)
Adapters=${Library}_adapters.conf
CORES=${SLURM_NTASKS:-20}
OUTPUTDIR=.

echo
echo Library=$Library
echo Adapters=$Adapters
echo Read1=$Read1
echo Read2=$Read2
echo CORES=$CORES
echo



#set -x
if [[ -z "$Library" || -z "$Read1" || -z "$Read2" || -z "$Adapters" || -z "$CORES" ]] ; then
  echo "Usage: $0  LibraryName [ cores ]"
  echo
  echo "trimmed reads and cutadapt report will be in directory '$OUTPUTDIR'"
  echo
  exit 1;
fi

[[ ! -e "${Read1}" ]] && { [[ -L "${Read1}" ]] && { echo link to read 1 file ${Read1} is broken; exit 1; } || { echo could not find read 1 file ${Read1}; exit 1; } }
[[ ! -e "${Read2}" ]] && { [[ -L "${Read2}" ]] && { echo link to read 2 file ${Read2} is broken; exit 1; } || { echo could not find read 2 file ${Read2}; exit 1; } }
[[ ! -e "${Adapters}" ]] && { [[ -L "${Adapters}" ]] && { echo link to adapters file ${Adapters} is broken; exit 1; } || { echo could not find adapters file ${Adapters}; exit 1; } }

#set +x
module load bioinfo-tools
module load cutadapt/2.3

echo
echo Library=$Library
echo Adapters=$Adapters
echo Read1=$Read1
echo Read2=$Read2
echo

#set -x

mkdir -p $OUTPUTDIR

Output1=$OUTPUTDIR/${Read1%.fastq.gz}.trimmed.fastq.gz
Output2=$OUTPUTDIR/${Read2%.fastq.gz}.trimmed.fastq.gz
Tooshort1=$OUTPUTDIR/${Read1%.fastq.gz}.tooshort.fastq.gz
Tooshort2=$OUTPUTDIR/${Read2%.fastq.gz}.tooshort.fastq.gz
Cutadapt_Report=$OUTPUTDIR/$Library.cutReport

echo 
echo Output1=$Output1
echo Output2=$Output2
echo Tooshort1=$Tooshort1   CANNOT BE USED WITH --cores
echo Tooshort2=$Tooshort2   CANNOT BE USED WITH --cores
echo Cutadapt_report=$Cutadapt_Report
echo 

set -x

$cutadapt $(<$Adapters) --cores $CORES --overlap 8 --pair-filter=any --minimum-length=20 --output $Output1 --paired-output $Output2 $Read1 $Read2 > $Cutadapt_Report


