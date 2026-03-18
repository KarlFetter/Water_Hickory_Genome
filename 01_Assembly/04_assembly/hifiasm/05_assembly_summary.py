#!/usr/bin/env python3
"""
Generate assembly summary tables from seqkit, QUAST, and BUSCO results.

Reads QC data from two assembly sets (reads_from_vega, hifiasm_centrifuge_reads),
each with primary, hap1, and hap2 assemblies. Outputs:
  1. assembly_summary.txt  — plain-text table
  2. assembly_summary.md   — markdown table (also printed to stdout)
"""

import re
from pathlib import Path

# ============================================================
# Configuration
# ============================================================

QC_DIR = Path("/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/qc")

ASSEMBLY_SETS = ["reads_from_vega", "hifiasm_centrifuge_reads"]
HAPLOTYPES = ["primary", "hap1", "hap2"]

# Column labels: (assembly_set, haplotype)
COLUMNS = [(asm, hap) for asm in ASSEMBLY_SETS for hap in HAPLOTYPES]
COL_LABELS = [f"{asm}::{hap}" for asm, hap in COLUMNS]


# ============================================================
# Parsers
# ============================================================

def parse_seqkit(asm_set, hap):
    """Parse seqkit stats -a output (tab-delimited, 2 lines: header + data)."""
    path = QC_DIR / asm_set / "seqkit" / f"{hap}_stats.txt"
    if not path.exists():
        return {}

    lines = path.read_text().splitlines()
    if len(lines) < 2:
        return {}

    headers = lines[0].split()
    values = lines[1].split()
    data = dict(zip(headers, values))

    return {
        "Num Sequences":  data.get("num_seqs", "N/A"),
        "Total Length":   data.get("sum_len", "N/A"),
        "Min Length":     data.get("min_len", "N/A"),
        "Avg Length":     data.get("avg_len", "N/A"),
        "Max Length":     data.get("max_len", "N/A"),
        "N50 (seqkit)":  data.get("N50", "N/A"),
    }


def parse_quast(asm_set, hap):
    """Parse QUAST report.tsv (two-column: metric name \\t value)."""
    path = QC_DIR / asm_set / "quast" / hap / "report.tsv"
    if not path.exists():
        return {}

    wanted = {
        "# contigs":      "Contigs",
        "Largest contig": "Largest Contig",
        "Total length":   "Total Length (QUAST)",
        "GC (%)":         "GC (%)",
        "N50":            "N50",
        "N75":            "N75",
        "L50":            "L50",
        "L75":            "L75",
    }

    results = {v: "N/A" for v in wanted.values()}
    for line in path.read_text().splitlines():
        parts = line.split("\t")
        if len(parts) >= 2 and parts[0] in wanted:
            results[wanted[parts[0]]] = parts[1]
    return results


def parse_busco(asm_set, hap):
    """Parse BUSCO short_summary*.txt and split into individual metrics."""
    busco_dir = QC_DIR / asm_set / "busco" / f"{hap}_busco"
    summary_files = list(busco_dir.glob("short_summary*.txt"))
    na = {k: "N/A" for k in [
        "BUSCO Complete (%)", "BUSCO Single-copy (%)", "BUSCO Duplicated (%)",
        "BUSCO Fragmented (%)", "BUSCO Missing (%)", "BUSCO Erroneous (%)"
    ]}
    if not summary_files:
        return na

    content = summary_files[0].read_text()

    # Example: C:98.7%[S:91.0%,D:7.7%],F:0.9%,M:0.4%,n:1614,E:3.3%
    # E field is optional (BUSCO 5.7+)
    match = re.search(
        r"C:([\d.]+)%\[S:([\d.]+)%,D:([\d.]+)%\],F:([\d.]+)%,M:([\d.]+)%,n:\d+(?:,E:([\d.]+)%)?",
        content,
    )
    if match:
        return {
            "BUSCO Complete (%)":    match.group(1),
            "BUSCO Single-copy (%)": match.group(2),
            "BUSCO Duplicated (%)":  match.group(3),
            "BUSCO Fragmented (%)":  match.group(4),
            "BUSCO Missing (%)":     match.group(5),
            "BUSCO Erroneous (%)":   match.group(6) if match.group(6) else "N/A",
        }

    return na


# ============================================================
# Build the table
# ============================================================

# Ordered list of (metric_name, source) — determines row order
METRIC_GROUPS = [
    ("seqkit",  ["Num Sequences", "Total Length", "Min Length", "Avg Length", "Max Length", "N50 (seqkit)"]),
    ("quast",   ["Contigs", "Largest Contig", "Total Length (QUAST)", "GC (%)", "N50", "N75", "L50", "L75"]),
    ("busco",   ["BUSCO Complete (%)", "BUSCO Single-copy (%)", "BUSCO Duplicated (%)",
                 "BUSCO Fragmented (%)", "BUSCO Missing (%)", "BUSCO Erroneous (%)"]),
]


def collect_data():
    """Return {(asm_set, hap): {metric: value}} for every column."""
    data = {}
    for asm_set, hap in COLUMNS:
        merged = {}
        merged.update(parse_seqkit(asm_set, hap))
        merged.update(parse_quast(asm_set, hap))
        merged.update(parse_busco(asm_set, hap))
        data[(asm_set, hap)] = merged
    return data


def all_metrics():
    """Flat ordered list of metric names."""
    return [m for _, metrics in METRIC_GROUPS for m in metrics]


# ============================================================
# Output formatters
# ============================================================

def write_txt(data, out_path):
    """Write a plain-text aligned table."""
    metrics = all_metrics()
    header = ["Metric"] + COL_LABELS

    # Build rows
    rows = [header]
    for metric in metrics:
        row = [metric]
        for col in COLUMNS:
            row.append(data[col].get(metric, "N/A"))
        rows.append(row)

    # Calculate column widths
    widths = [max(len(str(row[i])) for row in rows) for i in range(len(header))]

    lines = []
    for i, row in enumerate(rows):
        line = "  ".join(str(cell).ljust(widths[j]) for j, cell in enumerate(row))
        lines.append(line)
        if i == 0:
            lines.append("  ".join("-" * w for w in widths))

    out_path.write_text("\n".join(lines) + "\n")
    print(f"Plain-text summary written to: {out_path}")


def write_md(data, out_path):
    """Write a markdown table."""
    metrics = all_metrics()
    header = ["Metric"] + COL_LABELS
    sep = [":---"] + ["---:"] * len(COL_LABELS)

    rows = [header, sep]
    for metric in metrics:
        row = [metric]
        for col in COLUMNS:
            row.append(data[col].get(metric, "N/A"))
        rows.append(row)

    lines = ["| " + " | ".join(row) + " |" for row in rows]

    out_path.write_text("\n".join(lines) + "\n")
    print(f"Markdown summary written to: {out_path}")

    # Also print to stdout
    print()
    print("\n".join(lines))


# ============================================================
# Main
# ============================================================

def main():
    data = collect_data()
    write_txt(data, QC_DIR / "assembly_summary.txt")
    write_md(data, QC_DIR / "assembly_summary.md")


if __name__ == "__main__":
    main()
