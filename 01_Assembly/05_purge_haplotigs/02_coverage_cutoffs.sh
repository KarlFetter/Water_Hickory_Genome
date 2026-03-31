#!/bin/bash
#SBATCH --job-name=PURGEDUPS_COV
#SBATCH --partition=ceres
#SBATCH --time=12:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --mem=64G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

module load purge_dups
module load minimap2

# ============================================================
# purge_dups — Step 2: Coverage histogram, cutoffs, self-align
# ============================================================
# 1. pbcstat   — compute per-base and per-read coverage stats
#                from the PAF produced in step 1
# 2. calcuts   — determine coverage thresholds for haplotig
#                classification (low, mid, high cutoffs)
# 3. split_fa  — split primary assembly at gaps (N runs) so
#                self-alignment doesn't span gap regions
# 4. minimap2  — self-alignment of the split assembly to
#                detect overlaps between duplicated contigs
#
# Run order:
#   01_align_reads.sh
#   02_coverage_cutoffs.sh  <-- this script
#   03_purge.sh
# ============================================================

THREADS=32
ASSEMBLY=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/reads_from_vega/carya_aquatica.bp.p_ctg.fa.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/05_purge_haplotigs/hifiasm

cd "${OUTDIR}"

# --- 1. Build coverage statistics from read alignments ------
echo "[$(date)] Running pbcstat"
pbcstat "${OUTDIR}/reads_to_assembly.paf.gz"
# Outputs: PB.base.cov  PB.stat

# --- 2. Calculate coverage cutoffs --------------------------
echo "[$(date)] Running calcuts"
calcuts PB.stat > cutoffs 2> calcults.log

echo "[$(date)] Coverage cutoffs:"
cat cutoffs

# --- 3. Split assembly at N-gaps for self-alignment ---------
echo "[$(date)] Splitting assembly at N-gaps"
split_fa "${ASSEMBLY}" > "${OUTDIR}/assembly.split.fa"

# --- 4. Self-alignment of the split assembly ----------------
echo "[$(date)] Running self-alignment"
minimap2 \
    -xasm5 \
    -DP \
    -t ${THREADS} \
    "${OUTDIR}/assembly.split.fa" \
    "${OUTDIR}/assembly.split.fa" \
    | gzip -c > "${OUTDIR}/assembly.split.self.paf.gz"

echo "[$(date)] Step 2 complete. Ready to run 03_purge.sh"
