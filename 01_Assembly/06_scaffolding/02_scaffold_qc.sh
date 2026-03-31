#!/bin/bash
#SBATCH --job-name=SCAFFOLD_QC
#SBATCH --partition=ceres
#SBATCH --time=2:00:00
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

set -euo pipefail

# ============================================================
# Scaffold QC — compare pre- and post-scaffolding assemblies
# ============================================================
# Runs seqkit stats on:
#   1. Purged primary assembly  (input to SAMBA)
#   2. SAMBA scaffold output    (output of 01_samba_scaffold.sh)
#
# Key metrics to compare:
#   - Contig/scaffold count     (expect fewer after scaffolding)
#   - N50                       (expect higher after scaffolding)
#   - Total length              (should be ~same; SAMBA fills gaps
#                                with real sequence, not N-pads)
#   - Largest sequence          (expect larger after scaffolding)
#
# Run order:
#   01_samba_scaffold.sh
#   02_scaffold_qc.sh  <-- this script
# ============================================================

PURGED=/90daydata/tgl_seqdata/carya_acquatica/assembly/05_purge_haplotigs/hifiasm/purged.fa
SCAFFOLDS=/90daydata/tgl_seqdata/carya_acquatica/assembly/06_scaffolding/carya_aquatica_primary.fa
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/06_scaffolding

# Verify inputs exist
[[ -f "${PURGED}" ]]    || { echo "ERROR: Purged assembly not found: ${PURGED}"; exit 1; }
[[ -f "${SCAFFOLDS}" ]] || { echo "ERROR: Scaffold FASTA not found: ${SCAFFOLDS}"; exit 1; }

echo "[$(date)] Assembly QC — pre vs post scaffolding"
echo "============================================================"

echo ""
echo "--- Purged primary assembly (pre-scaffolding) ---"
seqkit stats -a "${PURGED}" | column -t

echo ""
echo "--- SAMBA scaffolds (post-scaffolding) ---"
seqkit stats -a "${SCAFFOLDS}" | column -t

echo ""
echo "--- Scaffold size distribution (post-scaffolding, sorted) ---"
seqkit fx2tab --name --length "${SCAFFOLDS}" \
    | awk '{print $2}' \
    | sort -rn \
    | awk 'BEGIN{print "rank\tlength_bp"} {print NR"\t"$1}' \
    > "${OUTDIR}/scaffold_sizes_post.txt"

echo "  Written to: ${OUTDIR}/scaffold_sizes_post.txt"
echo "  Top 20 scaffolds:"
head -21 "${OUTDIR}/scaffold_sizes_post.txt" | column -t

echo ""
echo "[$(date)] QC complete"
