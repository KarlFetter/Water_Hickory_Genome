#!/bin/bash
#SBATCH --job-name=SCAFFOLD_SIZE
#SBATCH --partition=ceres
#SBATCH --time=180:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=16G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

# ============================================================
# Scaffold Size Distribution — Carya aquatica primary assembly
# ============================================================
# Extracts per-contig lengths from the hifiasm primary assembly
# using seqkit, then generates logged/unlogged bar plots with
# the scaffold_histogram.py script.
# ============================================================

ASSEMBLY=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/reads_from_vega/carya_aquatica.bp.p_ctg.fa.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/contig_graph
SCRIPT=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/scaffold_histogram.py

mkdir -p "${OUTDIR}"

# Extract contig name + length, keep only the length column
seqkit fx2tab --name --length "${ASSEMBLY}" \
    | awk '{print $2}' \
    > "${OUTDIR}/scaffold_sizes.txt"

echo "Scaffold sizes written to ${OUTDIR}/scaffold_sizes.txt"
echo "Number of contigs: $(wc -l < "${OUTDIR}/scaffold_sizes.txt")"

# Generate histograms (logged and unlogged)
python3 "${SCRIPT}" \
    "${OUTDIR}/scaffold_sizes.txt" \
    "${OUTDIR}/scaffold_histogram"

echo "Done. Figures saved to ${OUTDIR}/"
