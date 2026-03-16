#!/bin/bash
#SBATCH --job-name=CENTRIFUGE_HIFI
#SBATCH --partition=ceres
#SBATCH --time=180:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=150G
#SBATCH --mail-user=karl.fetter@usda.gov
#SBATCH --mail-type=END
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH -A tgl_seqdata

module load centrifuge
module load seqkit

# ============================================================
# Centrifuge Contamination Filtering for HiFi Reads
# ============================================================

THREADS=8
DB=/project/tgl_seqdata/databases/centrifuge/hpvf
READS=/90daydata/tgl_seqdata/carya_acquatica/assembly/01_raw_reads/carya_aquatica_hifi.fastq.gz
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/02_quality_control/centrifuge

mkdir -p ${OUTDIR}

# Run centrifuge
echo "$(date): Running Centrifuge..."
centrifuge \
    -x ${DB} \
    -U ${READS} \
    -S ${OUTDIR}/classification.tsv \
    --report-file ${OUTDIR}/report.tsv \
    --min-hitlen 50 \
    --threads ${THREADS}

echo "$(date): Centrifuge classification complete."

# Generate Kraken-style report
centrifuge-kreport -x ${DB} ${OUTDIR}/classification.tsv > ${OUTDIR}/kreport.txt

# Extract unclassified read IDs (clean plant reads)
grep 'unclassified' ${OUTDIR}/classification.tsv | \
    cut -f 1 | \
    sort | \
    uniq > ${OUTDIR}/unclassified_ids.txt

# Extract clean reads
echo "$(date): Extracting clean reads..."
seqkit grep -f ${OUTDIR}/unclassified_ids.txt \
    ${READS} \
    -o ${OUTDIR}/carya_aquatica_hifi_clean.fastq.gz

echo "$(date): Clean reads extracted."

# Extract contaminant read IDs (classified reads)
grep -v 'unclassified' ${OUTDIR}/classification.tsv | \
    awk 'NR>1 {print $1}' | \
    sort | \
    uniq > ${OUTDIR}/contaminant_ids.txt

# Extract contaminant reads
echo "$(date): Extracting contaminant reads..."
seqkit grep -f ${OUTDIR}/contaminant_ids.txt \
    ${READS} \
    -o ${OUTDIR}/carya_aquatica_hifi_contaminants.fastq.gz

echo "$(date): Contaminant reads extracted."

# ============================================================
# Summary statistics
# ============================================================
TOTAL_READS=$(seqkit stats -T ${READS} | awk 'NR==2 {print $4}')
CLEAN_READS=$(wc -l < ${OUTDIR}/unclassified_ids.txt)
CONTAM_READS=$((TOTAL_READS - CLEAN_READS))
CONTAM_PCT=$(echo "scale=2; ${CONTAM_READS} * 100 / ${TOTAL_READS}" | bc)

echo "============================================" > ${OUTDIR}/centrifuge_summary.txt
echo "Centrifuge Filtering Summary" >> ${OUTDIR}/centrifuge_summary.txt
echo "Species: Carya aquatica (Water Hickory)" >> ${OUTDIR}/centrifuge_summary.txt
echo "Data: PacBio Vega HiFi" >> ${OUTDIR}/centrifuge_summary.txt
echo "============================================" >> ${OUTDIR}/centrifuge_summary.txt
echo "Total reads: ${TOTAL_READS}" >> ${OUTDIR}/centrifuge_summary.txt
echo "Clean reads: ${CLEAN_READS}" >> ${OUTDIR}/centrifuge_summary.txt
echo "Contaminated reads: ${CONTAM_READS} (${CONTAM_PCT}%)" >> ${OUTDIR}/centrifuge_summary.txt
echo "============================================" >> ${OUTDIR}/centrifuge_summary.txt

cat ${OUTDIR}/centrifuge_summary.txt
echo "$(date): Done!"
