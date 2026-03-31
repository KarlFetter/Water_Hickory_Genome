#!/bin/bash
#SBATCH --job-name=PURGEDUPS_PURGE
#SBATCH --partition=ceres
#SBATCH --time=4:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=32G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

module load purge_dups
module load seqkit

# ============================================================
# purge_dups — Step 3: Purge haplotigs and extract sequences
# ============================================================
# 1. purge_dups — classify contigs using coverage + self-aln
#                 and output a BED of duplicated regions
# 2. get_seqs   — extract purged primary + haplotig FASTAs
# 3. seqkit     — quick QC stats on both output assemblies
#
# Run order:
#   01_align_reads.sh
#   02_coverage_cutoffs.sh
#   03_purge.sh  <-- this script
#
# Outputs:
#   purged.fa       — purged primary assembly (use this going forward)
#   hap.fa          — haplotigs removed from primary
#   dups.bed        — coordinates of identified duplicates
# ============================================================

OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/05_purge_haplotigs/hifiasm
ASSEMBLY=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/reads_from_vega/carya_aquatica.bp.p_ctg.fa.gz

cd "${OUTDIR}"

# --- 1. Identify and classify duplicated regions ------------
echo "[$(date)] Running purge_dups"
purge_dups \
    -2 \
    -T cutoffs \
    -c PB.base.cov \
    "${OUTDIR}/assembly.split.self.paf.gz" \
    > dups.bed \
    2> purge_dups.log

echo "[$(date)] Duplicated regions written to dups.bed"
echo "  Total regions classified: $(wc -l < dups.bed)"

# --- 2. Extract purged primary and haplotig sequences -------
echo "[$(date)] Running get_seqs"
get_seqs \
    -e dups.bed \
    "${ASSEMBLY}"
# Outputs: purged.fa  hap.fa

# --- 3. Assembly QC stats -----------------------------------
echo "[$(date)] Assembly statistics (purged primary):"
seqkit stats -a purged.fa

echo "[$(date)] Assembly statistics (haplotigs):"
seqkit stats -a hap.fa

echo ""
echo "[$(date)] Done. Key outputs:"
echo "  Purged primary: ${OUTDIR}/purged.fa"
echo "  Haplotigs:      ${OUTDIR}/hap.fa"
echo "  Dup regions:    ${OUTDIR}/dups.bed"
