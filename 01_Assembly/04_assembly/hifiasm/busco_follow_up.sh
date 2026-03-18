#!/bin/bash
#SBATCH --job-name=BUSCO_hap1_hap2
#SBATCH --partition=ceres
#SBATCH --time=48:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --mem=128G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

module load busco5/5.7.1

# ============================================================
# BUSCO for hap1 and hap2 assemblies
# (primary is already finished)
# ============================================================

THREADS=16
BUSCODIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/qc/hifiasm_centrifuge_reads/busco
BUSCO_DB=/project/tgl_seqdata/databases/BUSCO/busco_downloads/lineages/embryophyta_odb10

# Input compressed files
HAP1_GZ=${BUSCODIR}/carya_aquatica.bp.hap1.p_ctg.fa.gz
HAP2_GZ=${BUSCODIR}/carya_aquatica.bp.hap2.p_ctg.fa.gz

# Decompress (BUSCO requires uncompressed FASTA)
echo "$(date): Decompressing hap1 and hap2 assemblies..."
gunzip -k ${HAP1_GZ}
gunzip -k ${HAP2_GZ}

HAP1_FA=${BUSCODIR}/carya_aquatica.bp.hap1.p_ctg.fa
HAP2_FA=${BUSCODIR}/carya_aquatica.bp.hap2.p_ctg.fa

# Run BUSCO on hap1
echo "$(date): Running BUSCO on hap1..."
busco --offline -f \
    -i ${HAP1_FA} \
    -o hap1_busco \
    -l ${BUSCO_DB} \
    -m genome \
    -c ${THREADS} \
    --out_path ${BUSCODIR}

# Run BUSCO on hap2
echo "$(date): Running BUSCO on hap2..."
busco --offline -f \
    -i ${HAP2_FA} \
    -o hap2_busco \
    -l ${BUSCO_DB} \
    -m genome \
    -c ${THREADS} \
    --out_path ${BUSCODIR}

# Clean up decompressed files
echo "$(date): Removing decompressed FASTA files..."
rm ${HAP1_FA} ${HAP2_FA}

echo "$(date): Done."
