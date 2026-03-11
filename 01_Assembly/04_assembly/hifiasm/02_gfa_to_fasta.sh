#!/bin/bash
#SBATCH --job-name=GFA_TO_FASTA
#SBATCH --partition=ceres
#SBATCH --time=12:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

# ============================================================
# Convert hifiasm GFA output to FASTA
# ============================================================

INDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm
PREFIX=carya_aquatica

cd ${INDIR}

# Convert primary contigs
awk '/^S/{print ">"$2;print $3}' ${PREFIX}.bp.p_ctg.gfa > ${PREFIX}.bp.p_ctg.fa

# Convert haplotype 1 contigs
awk '/^S/{print ">"$2;print $3}' ${PREFIX}.bp.hap1.p_ctg.gfa > ${PREFIX}.bp.hap1.p_ctg.fa

# Convert haplotype 2 contigs
awk '/^S/{print ">"$2;print $3}' ${PREFIX}.bp.hap2.p_ctg.gfa > ${PREFIX}.bp.hap2.p_ctg.fa

# Compress
gzip ${PREFIX}.bp.p_ctg.fa
gzip ${PREFIX}.bp.hap1.p_ctg.fa
gzip ${PREFIX}.bp.hap2.p_ctg.fa

echo "$(date): GFA to FASTA conversion complete."
ls -lh ${PREFIX}.bp.*.fa.gz
