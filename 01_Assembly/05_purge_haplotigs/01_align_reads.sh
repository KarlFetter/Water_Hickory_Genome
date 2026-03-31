#!/bin/bash
#SBATCH --job-name=PURGEDUPS_ALIGN
#SBATCH --partition=ceres
#SBATCH --time=24:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --mem=128G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

module load minimap2

# ============================================================
# purge_dups — Step 1: Align HiFi reads to primary assembly
# ============================================================
# Map HiFi reads back to the primary assembly using map-hifi
# preset. Output is a gzipped PAF used by pbcstat in step 2.
#
# Run order:
#   01_align_reads.sh  <-- this script
#   02_coverage_cutoffs.sh
#   03_purge.sh
# ============================================================

THREADS=32
ASSEMBLY=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/reads_from_vega/carya_aquatica.bp.p_ctg.fa.gz
READS=/90daydata/tgl_seqdata/carya_acquatica/assembly/01_raw_reads/carya_aquatica_hifi.fastq.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/05_purge_haplotigs/hifiasm

mkdir -p "${OUTDIR}"
cd "${OUTDIR}"

echo "[$(date)] Starting HiFi read alignment to primary assembly"

minimap2 \
    -xmap-hifi \
    -t ${THREADS} \
    "${ASSEMBLY}" \
    "${READS}" \
    | gzip -c > "${OUTDIR}/reads_to_assembly.paf.gz"

echo "[$(date)] Alignment complete: ${OUTDIR}/reads_to_assembly.paf.gz"
