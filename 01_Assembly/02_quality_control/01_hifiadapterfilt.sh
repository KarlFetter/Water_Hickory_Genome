#!/bin/bash
#SBATCH --job-name=HIFIADAPTERFILT
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
# HiFiAdapterFilt — remove residual PacBio adapter sequences
# https://github.com/sheinasim/HiFiAdapterFilt
# ============================================================

# Load dependencies
module load blast+
module load bamtools

# Set up paths to HiFiAdapterFilt
export PATH=$PATH:~/bin/HiFiAdapterFilt
export PATH=$PATH:~/bin/HiFiAdapterFilt/DB

THREADS=8
INDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/01_raw_reads
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/02_quality_control/adapter_filt

mkdir -p ${OUTDIR}
cd ${OUTDIR}

# Symlink input for HiFiAdapterFilt (expects .fastq.gz in working dir)
ln -sf ${INDIR}/carya_aquatica_hifi.fastq.gz .

# Run adapter filtering
bash hifiadapterfilt.sh  \
    -p carya_aquatica_hifi \
    -t ${THREADS} \
    -o ${OUTDIR}

echo "$(date): Adapter filtering complete."
echo "Filtered reads: ${OUTDIR}/carya_aquatica_hifi.filt.fastq.gz"
echo "Stats: ${OUTDIR}/carya_aquatica_hifi.stats"
