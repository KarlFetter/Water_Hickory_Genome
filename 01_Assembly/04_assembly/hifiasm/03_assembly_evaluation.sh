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
module load busco
module load seqkit

# ============================================================
# Assembly evaluation: seqkit stats, QUAST, BUSCO
# ============================================================

THREADS=16
INDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm
OUTDIR=/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/qc
PREFIX=carya_aquatica
BUSCO_DB=/project/tgl_seqdata/databases/BUSCO/embryophyta_odb10

mkdir -p ${OUTDIR}/{seqkit,quast,busco}
cd ${OUTDIR}

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
# BUSCO
# ============================================================
busco -i ${PRIMARY} -o primary_busco -l ${BUSCO_DB} -m genome -c ${THREADS} --out_path ${OUTDIR}/busco
busco -i ${HAP1} -o hap1_busco -l ${BUSCO_DB} -m genome -c ${THREADS} --out_path ${OUTDIR}/busco
busco -i ${HAP2} -o hap2_busco -l ${BUSCO_DB} -m genome -c ${THREADS} --out_path ${OUTDIR}/busco

echo "$(date): Assembly evaluation complete."
