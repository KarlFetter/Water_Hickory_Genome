#!/bin/bash
#SBATCH --job-name=KMERFREQ_GENOMESIZE
#SBATCH --partition=ceres
#SBATCH --time=48:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --mem=128G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

module load seqkit

# ============================================================
# kmerfreq-based genome size estimation (alternative to Jellyfish)
# ============================================================

KMERFREQ=/home/karl.fetter/bin/kmerfreq/kmerfreq
KMER=17
THREADS=16
READS=/90daydata/tgl_seqdata/carya_acquatica/assembly/02_quality_control/centrifuge/carya_aquatica_hifi_clean.fastq.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/03_genome_size
PREFIX=carya_aquatica_k${KMER}

mkdir -p ${OUTDIR}
cd ${OUTDIR}

# Convert to one-line fastq format (required by kmerfreq)
seqkit seq -w 0 ${READS} -o carya_aquatica_clean_oneline.fastq.gz

# Create library file
echo "${OUTDIR}/carya_aquatica_clean_oneline.fastq.gz" > reads.lib

# Run kmerfreq
${KMERFREQ} \
    -k ${KMER} \
    -t ${THREADS} \
    -p ${PREFIX} \
    reads.lib
