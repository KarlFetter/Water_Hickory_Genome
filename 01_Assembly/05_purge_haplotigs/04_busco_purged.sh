#!/bin/bash
#SBATCH --job-name=BUSCO_purged
#SBATCH --partition=ceres
#SBATCH --time=48:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --mem=500G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

module load busco5/5.7.1

# ============================================================
# BUSCO — purged primary assembly (post purge_dups)
# ============================================================
# Evaluates gene completeness of the purged primary assembly
# using the embryophyta_odb10 lineage database.
#
# Run after 03_purge.sh. Compare results against the pre-purge
# primary assembly (BUSCO complete: 98.7%, duplicated: 7.7%).
# Expected outcome: duplicated % should drop substantially.
# ============================================================

THREADS=16
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/05_purge_haplotigs/hifiasm
BUSCO_DB=/project/tgl_seqdata/databases/BUSCO/busco_downloads/lineages/embryophyta_odb10

PURGED_FA=${OUTDIR}/purged.fa

[[ -f "${PURGED_FA}" ]] || { echo "ERROR: purged.fa not found: ${PURGED_FA}"; exit 1; }

echo "$(date): Running BUSCO on purged primary assembly..."

busco --offline -f \
    -i ${PURGED_FA} \
    -o purged_busco \
    -l ${BUSCO_DB} \
    -m genome \
    -c ${THREADS} \
    --out_path ${OUTDIR}

echo "$(date): Done. Results in ${OUTDIR}/purged_busco/"
