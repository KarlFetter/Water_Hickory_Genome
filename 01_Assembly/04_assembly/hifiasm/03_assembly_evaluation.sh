#!/bin/bash
#SBATCH --job-name=ASSEMBLY_EVAL
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

module load quast
module load busco5/5.7.1
module load seqkit

# ============================================================
# Assembly evaluation: seqkit stats, QUAST, BUSCO
# ============================================================

THREADS=16
BASEDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm
QCDIR=${BASEDIR}/qc
PREFIX=carya_aquatica
BUSCO_DB=/project/tgl_seqdata/databases/BUSCO/busco_downloads/lineages/embryophyta_odb10

ASSEMBLIES=(
    "reads_from_vega"
    "hifiasm_centrifuge_reads"
)

for ASM in "${ASSEMBLIES[@]}"; do
    echo "$(date): Evaluating assembly: ${ASM}"

    INDIR=${BASEDIR}/${ASM}
    OUTDIR=${QCDIR}/${ASM}

    mkdir -p ${OUTDIR}/{seqkit,quast,busco}

    # Assembly files
    PRIMARY=${INDIR}/${PREFIX}.bp.p_ctg.fa.gz
    HAP1=${INDIR}/${PREFIX}.bp.hap1.p_ctg.fa.gz
    HAP2=${INDIR}/${PREFIX}.bp.hap2.p_ctg.fa.gz

    # ============================================================
    # Seqkit Stats
    # ============================================================
    seqkit stats -a ${PRIMARY} > ${OUTDIR}/seqkit/primary_stats.txt
    seqkit stats -a ${HAP1} > ${OUTDIR}/seqkit/hap1_stats.txt
    seqkit stats -a ${HAP2} > ${OUTDIR}/seqkit/hap2_stats.txt

    # ============================================================
    # QUAST
    # ============================================================
    quast.py -o ${OUTDIR}/quast/primary -t ${THREADS} --large ${PRIMARY}
    quast.py -o ${OUTDIR}/quast/hap1 -t ${THREADS} --large ${HAP1}
    quast.py -o ${OUTDIR}/quast/hap2 -t ${THREADS} --large ${HAP2}

    # ============================================================
    # BUSCO (requires uncompressed FASTA)
    # ============================================================
    PRIMARY_FA=${OUTDIR}/busco/${PREFIX}.bp.p_ctg.fa
    HAP1_FA=${OUTDIR}/busco/${PREFIX}.bp.hap1.p_ctg.fa
    HAP2_FA=${OUTDIR}/busco/${PREFIX}.bp.hap2.p_ctg.fa

    zcat ${PRIMARY} > ${PRIMARY_FA}
    zcat ${HAP1} > ${HAP1_FA}
    zcat ${HAP2} > ${HAP2_FA}

    busco --offline -f -i ${PRIMARY_FA} -o primary_busco -l ${BUSCO_DB} -m genome -c ${THREADS} --out_path ${OUTDIR}/busco
    busco --offline -f -i ${HAP1_FA} -o hap1_busco -l ${BUSCO_DB} -m genome -c ${THREADS} --out_path ${OUTDIR}/busco
    busco --offline -f -i ${HAP2_FA} -o hap2_busco -l ${BUSCO_DB} -m genome -c ${THREADS} --out_path ${OUTDIR}/busco

    # ============================================================
    # Recompress decompressed FASTA files
    # ============================================================
    gzip ${PRIMARY_FA}
    gzip ${HAP1_FA}
    gzip ${HAP2_FA}

    echo "$(date): ${ASM} evaluation complete."
done

# ============================================================
# Summary Report
# ============================================================

SUMMARY=${QCDIR}/assembly_summary.tsv

{
    # Header row
    printf "Metric"
    for ASM in "${ASSEMBLIES[@]}"; do
        for HAP in primary hap1 hap2; do
            printf "\t%s::%s" "${ASM}" "${HAP}"
        done
    done
    printf "\n"

    # --- Seqkit Stats ---
    # seqkit stats -a columns (tab-delimited):
    # 1:file 2:format 3:type 4:num_seqs 5:sum_len 6:min_len
    # 7:avg_len 8:max_len 9:Q1 10:Q2 11:Q3 12:sum_gap 13:N50
    for METRIC_PAIR in \
        "Num_Sequences:4" \
        "Total_Length:5" \
        "Min_Length:6" \
        "Avg_Length:7" \
        "Max_Length:8" \
        "N50_(seqkit):13"; do
        LABEL="${METRIC_PAIR%%:*}"
        COL="${METRIC_PAIR##*:}"
        printf "%s" "${LABEL}"
        for ASM in "${ASSEMBLIES[@]}"; do
            for HAP in primary hap1 hap2; do
                FILE="${QCDIR}/${ASM}/seqkit/${HAP}_stats.txt"
                VAL=$(awk -F'\t' 'NR==2{print $'"${COL}"'}' "${FILE}" 2>/dev/null)
                printf "\t%s" "${VAL:-NA}"
            done
        done
        printf "\n"
    done

    # --- QUAST ---
    for QMETRIC in \
        "# contigs" \
        "Largest contig" \
        "Total length" \
        "GC (%)" \
        "N50" \
        "N75" \
        "L50" \
        "L75"; do
        LABEL=$(echo "${QMETRIC}" | tr ' ' '_' | tr -d '#()')
        printf "%s" "${LABEL}"
        for ASM in "${ASSEMBLIES[@]}"; do
            for HAP in primary hap1 hap2; do
                RFILE="${QCDIR}/${ASM}/quast/${HAP}/report.tsv"
                VAL=$(awk -F'\t' -v m="${QMETRIC}" '$1==m{print $2}' "${RFILE}" 2>/dev/null)
                printf "\t%s" "${VAL:-NA}"
            done
        done
        printf "\n"
    done

    # --- BUSCO ---
    printf "BUSCO"
    for ASM in "${ASSEMBLIES[@]}"; do
        for HAP in primary hap1 hap2; do
            BFILE=$(ls ${QCDIR}/${ASM}/busco/${HAP}_busco/short_summary*.txt 2>/dev/null | head -1)
            if [[ -f "${BFILE}" ]]; then
                VAL=$(grep "C:" "${BFILE}" | sed 's/^[ \t]*//' | head -1)
            else
                VAL="NA"
            fi
            printf "\t%s" "${VAL}"
        done
    done
    printf "\n"

} > "${SUMMARY}"

echo ""
echo "============================================"
echo "         Assembly Summary Report"
echo "============================================"
column -t -s $'\t' "${SUMMARY}"
echo ""
echo "Full summary saved to: ${SUMMARY}"

echo "$(date): All assembly evaluations complete."