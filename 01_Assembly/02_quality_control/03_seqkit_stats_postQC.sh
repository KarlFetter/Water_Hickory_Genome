#!/bin/bash
#SBATCH --job-name=SEQKIT_POSTQC
#SBATCH --partition=ceres
#SBATCH --time=12:00:00
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

# ============================================================
# Post-QC read statistics and coverage estimate
# ============================================================

THREADS=8
READS=/90daydata/tgl_seqdata/carya_acquatica/assembly/02_quality_control/centrifuge/carya_aquatica_hifi_clean.fastq.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/02_quality_control

# Genome size estimate for Carya (pecan genome ~651 Mb; water hickory expected similar)
# Adjust this value once genome size estimation is complete
EXPECTED_SIZE=730000000

cd ${OUTDIR}

# Generate read statistics
seqkit stats -j ${THREADS} -a ${READS} > carya_aquatica_postQC_stats.txt
cat carya_aquatica_postQC_stats.txt

# Calculate coverage
TOTAL_BASES=$(seqkit stats -j ${THREADS} -T ${READS} | awk 'NR==2 {print $5}')
COVERAGE=$(echo "scale=2; ${TOTAL_BASES} / ${EXPECTED_SIZE}" | bc)
TOTAL_GB=$(echo "scale=2; ${TOTAL_BASES} / 1000000000" | bc)

echo "Total Bases: ${TOTAL_BASES}" > carya_aquatica_coverage.txt
echo "Total Gb: ${TOTAL_GB}" >> carya_aquatica_coverage.txt
echo "Expected Genome Size: ${EXPECTED_SIZE}" >> carya_aquatica_coverage.txt
echo "Estimated Coverage: ${COVERAGE}x" >> carya_aquatica_coverage.txt

cat carya_aquatica_coverage.txt
