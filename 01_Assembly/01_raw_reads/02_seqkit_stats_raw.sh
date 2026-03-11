#!/bin/bash
#SBATCH --job-name=SEQKIT_RAW
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

module load seqkit

# ============================================================
# Raw read statistics for HiFi FASTQ
# ============================================================

THREADS=8
READS=/90daydata/tgl_seqdata/carya_acquatica/assembly/01_raw_reads/carya_aquatica_hifi.fastq.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/01_raw_reads

cd ${OUTDIR}

seqkit stats -j ${THREADS} -a ${READS} > carya_aquatica_hifi_raw_stats.txt
cat carya_aquatica_hifi_raw_stats.txt
