#!/bin/bash
#SBATCH --job-name=NANOPLOT_RAW
#SBATCH --partition=ceres
#SBATCH --time=24:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=32G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

# ============================================================
# NanoPlot QC on raw HiFi reads
# ============================================================

NANOPLOT=~/.local/bin/NanoPlot
THREADS=8
READS=/90daydata/tgl_seqdata/carya_acquatica/assembly/01_raw_reads/carya_aquatica_hifi.fastq.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/01_raw_reads/nanoplot_raw

mkdir -p ${OUTDIR}

${NANOPLOT} -o ${OUTDIR} \
    --fastq ${READS} \
    --minlength 50 \
    --tsv_stats \
    -t ${THREADS}
