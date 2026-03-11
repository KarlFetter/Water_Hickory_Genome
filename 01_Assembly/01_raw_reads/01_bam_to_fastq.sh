#!/bin/bash
#SBATCH --job-name=BAM2FASTQ
#SBATCH --partition=ceres
#SBATCH --time=12:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=32G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

module load samtools

# ============================================================
# Convert PacBio HiFi BAM to FASTQ
# ============================================================

THREADS=8
INBAM=/project/tgl_seqdata/r21129_20260303_220348/1_A01/hifi_reads/m21129_260303_220936.hifi_reads.bc2001.bam
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/01_raw_reads
PREFIX=carya_aquatica_hifi

mkdir -p ${OUTDIR}

echo "$(date): Converting BAM to FASTQ..."

samtools fastq \
    -@ ${THREADS} \
    ${INBAM} | gzip > ${OUTDIR}/${PREFIX}.fastq.gz

echo "$(date): Conversion complete."
echo "$(date): Output: ${OUTDIR}/${PREFIX}.fastq.gz"

# Quick stats
module load seqkit
seqkit stats -a ${OUTDIR}/${PREFIX}.fastq.gz > ${OUTDIR}/${PREFIX}_stats.txt
cat ${OUTDIR}/${PREFIX}_stats.txt
