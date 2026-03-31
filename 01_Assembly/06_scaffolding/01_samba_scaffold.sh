#!/bin/bash
#SBATCH --job-name=SAMBA_SCAFFOLD
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

module load masurca/4.1.0

set -euo pipefail

# ============================================================
# SAMBA — HiFi-read scaffolding and gap-filling from contigs
# ============================================================
# SAMBA scaffolds and gap-fills directly from HiFi contigs in
# a single step (-d asm mode). Unlike ntLink, gap sequences are
# filled with real sequence rather than N-pads, yielding longer
# contigs and a more contiguous assembly.
#
# Input:
#   purged.fa                    — purged primary contigs
#                                  (05_purge_haplotigs/hifiasm/)
#   carya_aquatica_hifi.fastq.gz — raw HiFi reads
#
# Key parameters:
#   -d asm   — data type for PacBio HiFi reads
#   -m 3000  — minimum matching length; 2500 for small genomes
#              (<400 Mb), 5000 for large (2-3 Gbp); 3000
#              appropriate for ~673 Mb assembly
#   -t       — threads
#
# Output: purged.fa.after_samba.fa (written to OUTDIR/CWD)
#
# Run order:
#   (after 05_purge_haplotigs/03_purge.sh)
#   01_samba_scaffold.sh  <-- this script
#   02_scaffold_qc.sh
# ============================================================

THREADS=32
ASSEMBLY=/90daydata/tgl_seqdata/carya_acquatica/assembly/05_purge_haplotigs/hifiasm/purged.fa
READS=/90daydata/tgl_seqdata/carya_acquatica/assembly/01_raw_reads/carya_aquatica_hifi.fastq.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/06_scaffolding

mkdir -p "${OUTDIR}"
cd "${OUTDIR}"

# Verify inputs exist
[[ -f "${ASSEMBLY}" ]] || { echo "ERROR: Purged assembly not found: ${ASSEMBLY}"; exit 1; }
[[ -f "${READS}" ]]    || { echo "ERROR: Reads not found: ${READS}"; exit 1; }

echo "[$(date)] Starting SAMBA scaffolding + gap-filling"
echo "  Assembly:  ${ASSEMBLY}"
echo "  Reads:     ${READS}"
echo "  Mode:      -d asm (PacBio HiFi)"
echo "  Min match: 3000 bp"
echo "  Threads:   ${THREADS}"

samba.sh \
    -r "${ASSEMBLY}" \
    -q "${READS}" \
    -d asm \
    -m 3000 \
    -t ${THREADS}

echo "[$(date)] SAMBA complete"

# Rename SAMBA output to a clean, informative filename
mv "${OUTDIR}/purged.fa.after_samba.fa" "${OUTDIR}/carya_aquatica_primary.fa"

echo ""
echo "Output: ${OUTDIR}/carya_aquatica_primary.fa"
ls -lh "${OUTDIR}/carya_aquatica_primary.fa"
