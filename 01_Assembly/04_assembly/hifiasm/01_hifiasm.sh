#!/bin/bash
#SBATCH --job-name=HIFIASM
#SBATCH --partition=ceres
#SBATCH --time=180:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 64
#SBATCH --mem=750G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

module load hifiasm/0.25.0

# ============================================================
# hifiasm — HiFi-only assembly for Carya aquatica
# ============================================================

THREADS=64
READS=/90daydata/tgl_seqdata/carya_acquatica/assembly/02_quality_control/centrifuge/carya_aquatica_hifi_clean.fastq.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm
PREFIX=carya_aquatica

mkdir -p ${OUTDIR}
cd ${OUTDIR}

hifiasm \
    -o ${PREFIX} \
    -t ${THREADS} \
    ${READS}
