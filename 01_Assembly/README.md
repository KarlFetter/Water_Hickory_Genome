# Assembly Results — *Carya aquatica* (Water Hickory)

[← Back to Project Overview](../README.md)

---

## Assembly Workflow
1. Convert HiFi BAM to FASTQ
2. Raw read quality assessment (seqkit stats)
3. Contamination screening (Centrifuge)
4. Post-QC read assessment
5. Genome size estimation (Jellyfish + GenomeScope2)
6. *De novo* assembly (hifiasm)
7. Assembly evaluation (QUAST, BUSCO, seqkit, etc.)

> **Note:** Adapter filtering (HiFiAdapterFilt) was omitted because the PacBio Vega
> instrument removes adapters before outputting CCS/HiFi reads.

---

## Raw Reads

**Platform:** PacBio Vega  
**Flow Cell Type:** SMRTcell  
**Run ID:** r21129_20260303_220348  
**Instrument Software:** 1.1.0.47.44

### Summary Metrics

| Metric | Value |
|--------|-------|
| HiFi Reads | 4.9 M |
| HiFi Reads Yield | 64.85 Gb |
| HiFi Read Length (mean) | 13.12 kb |
| HiFi Read Length (median) | 12,372 bp |
| HiFi Read Length N50 | 14,980 bp |
| HiFi Read Quality (median) | Q37 |
| Base Quality ≥Q30 | 94.40% |
| HiFi Number of Passes (mean) | 12 |
| Missing Adapters | 2.08% |

### HiFi Read QC (seqkit stats)

| File | Format | Type | Num Seqs | Sum Len | Min Len | Avg Len | Max Len | Q1 | Q2 | Q3 | N50 | Q20 (%) | Q30 (%) | GC (%) |
|------|--------|------|----------|---------|---------|---------|---------|-----|-------|-------|-------|---------|---------|--------|
| carya_aquatica_hifi.fastq.gz | FASTQ | DNA | 4,935,257 | 64,756,226,301 | 106 | 13,121.1 | 64,392 | 8,839 | 12,372 | 16,457 | 14,979 | 97.74 | 94.41 | 36.2 |

### Read Length Distributions

<p align="center">
  <img src="../figures/sequencing_qc/Vega_HiFi/ccs_combined_readlength_hist_plot.png" width="48%" />
  &nbsp;
  <img src="../figures/sequencing_qc/Vega_HiFi/processed_reads_vs_polymerase_read_length.png" width="48%" />
</p>
<p align="center">
  <em>Left: HiFi combined read length distribution. Right: Processed reads vs. polymerase read length.</em>
</p>

### Code: BAM to FASTQ Conversion

The raw HiFi reads were delivered as a PacBio BAM file. We converted to FASTQ using `samtools`:

```bash
samtools fastq \
    -@ ${THREADS} \
    ${INBAM} | gzip > ${OUTDIR}/${PREFIX}.fastq.gz
```

Full script: [01_raw_reads/01_bam_to_fastq.sh](01_raw_reads/01_bam_to_fastq.sh)

---

## Quality Control

### Contamination Screening (Centrifuge)

Reads were classified against the Centrifuge `hpvf` database to identify and remove non-plant contaminants.

| Metric | Value |
|--------|-------|
| Total reads | 4,935,257 |
| Clean reads | 4,124,583 |
| Contaminated reads | 810,674 (16.42%) |

#### Top 10 Contaminant Species

| Species | Tax ID | Rank | Genome Size | Num Reads | Unique Reads | Abundance |
|---------|--------|------|-------------|-----------|--------------|-----------|
| *Homo sapiens* | 9606 | species | 3,117,275,501 | 752,230 | 277,467 | 1 |
| *Colletotrichum destructivum* | 34406 | species | 51,785,203 | 106,937 | 28,208 | 0 |
| *Remersonia thermophila* | 72144 | species | 27,414,229 | 74,614 | 16,575 | 0 |
| *Ascochyta rabiei* | 5454 | species | 40,901,820 | 52,910 | 11,378 | 0 |
| *Thermothelomyces thermophilus* ATCC 42464 | 573729 | strain | 38,744,216 | 49,647 | 11,569 | 0 |
| *Rhizoctonia solani* | 456999 | species | 40,703,773 | 37,318 | 31,989 | 0 |
| *Botrytis cinerea* B05.10 | 332648 | strain | 42,630,066 | 36,100 | 9,406 | 0 |
| *Puccinia triticina* | 208348 | species | 122,823,596 | 35,911 | 13,712 | 0 |
| *Purpureocillium takamizusanense* | 2060973 | species | 35,574,015 | 33,068 | 7,304 | 0 |
| *Pichia kudriavzevii* | 4909 | species | 10,812,555 | 22,351 | 745 | 0 |

Full script: [02_quality_control/01_centrifuge.sh](02_quality_control/01_centrifuge.sh)

---

## Genome Size Estimation

*Coming soon — Jellyfish k-mer counting + GenomeScope2*

---

## Assembly

*Coming soon — hifiasm de novo assembly*

---

## Assembly Evaluation

*Coming soon — QUAST, BUSCO, seqkit stats*
