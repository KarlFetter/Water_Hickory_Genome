# Water Hickory (*Carya aquatica*) Genome Assembly and Annotation

## Overview
This project contains scripts and documentation for the *de novo* genome assembly and annotation of water hickory (*Carya aquatica*) using PacBio Vega HiFi long-read sequencing data.

## Project Structure
```
Water Hickory/
├── 01_Assembly/
│   ├── 01_raw_reads/          # BAM-to-FASTQ conversion, raw read QC
│   ├── 02_quality_control/    # Adapter filtering, contamination screening, post-QC stats
│   ├── 03_genome_size/        # k-mer based genome size estimation
│   ├── 04_assembly/           # Genome assembly (hifiasm)
│   ├── 05_error_correction/   # Post-assembly polishing
│   ├── 06_purge_haplotigs/    # Haplotig purging
│   ├── 07_scaffolding/        # Chromosome-level scaffolding
│   └── 08_evaluation/         # Assembly quality assessment
├── 02_Annotation/
│   ├── 01_reads/              # RNA-seq / Iso-Seq data
│   ├── 02_quality_control/    # Annotation read QC
│   ├── 03_alignments/         # Read alignments
│   ├── 04_repeat_masking/     # Repeat identification and masking
│   ├── 05_gene_prediction/    # Ab initio and evidence-based gene prediction
│   └── 06_functional_annotation/  # Functional annotation
├── 03_Comparative_Genomics/
│   ├── 01_synteny/            # Synteny analysis
│   ├── 02_gene_family/        # Gene family analysis
│   └── 03_methylation/        # Methylation analysis
├── annotation_files/          # Annotation reference files
├── assembly_files/            # Assembly output files
├── figures/                   # Publication figures
├── metadata/                  # Sample and sequencing metadata
├── metrics/                   # QC metrics and summary tables
└── Sequencing_Reports/        # PacBio sequencing run reports
```

## Sequencing Data
- **Platform:** PacBio Revio (Vega chemistry)
- **Library type:** HiFi (CCS)
- **Raw data:** ~65 Gb HiFi reads
- **Raw data location:** `/project/tgl_seqdata/r21129_20260303_220348/1_A01/hifi_reads/`
- **Assembly working directory:** `/90daydata/tgl_seqdata/carya_acquatica/assembly/`

## Compute Environment
- **HPC:** USDA ARS SCINet Ceres cluster
- **Scheduler:** SLURM
- **Allocation:** `tgl_seqdata`

## Workflow & Results
- **[Assembly](01_Assembly/README.md)** — Raw read QC, assembly metrics, BUSCO scores, and figures

## Assembly Workflow
1. Convert HiFi BAM to FASTQ
2. Raw read quality assessment (seqkit stats)
3. Adapter filtering (HiFiAdapterFilt)
4. Contamination screening (Centrifuge)
5. Post-QC read assessment
6. Genome size estimation (Jellyfish + GenomeScope2)
7. *De novo* assembly (hifiasm)
8. Assembly evaluation (QUAST, BUSCO, seqkit)

## Contact
Karl Fetter — karl.fetter@usda.gov  
USDA ARS Southeast Area, Byron, GA  
Tree Genomics Lab
