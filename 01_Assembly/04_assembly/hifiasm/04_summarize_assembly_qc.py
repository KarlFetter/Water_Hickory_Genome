#!/usr/bin/env python3
"""
Summarize BUSCO and QUAST results for hifiasm assemblies.
Outputs a combined summary table for primary, hap1, and hap2 assemblies.
"""

import re
import csv
from pathlib import Path

QC_DIR = Path("/90daydata/tgl_seqdata/carya_acquatica/assembly/04_assembly/hifiasm/qc")
OUTPUT_FILE = QC_DIR / "assembly_summary.tsv"
ASSEMBLIES = ["primary", "hap1", "hap2"]


def parse_busco_short_summary(assembly):
    summary_files = list(QC_DIR.glob(f"busco/{assembly}_busco/short_summary*.txt"))
    na = {"busco_complete": "N/A", "busco_single": "N/A", "busco_duplicated": "N/A",
          "busco_fragmented": "N/A", "busco_missing": "N/A", "busco_total": "N/A"}
    if not summary_files:
        return na

    with open(summary_files[0], 'r') as f:
        content = f.read()

    match = re.search(r'C:([\d.]+)%\[S:([\d.]+)%,D:([\d.]+)%\],F:([\d.]+)%,M:([\d.]+)%,n:(\d+)', content)
    if match:
        return {
            "busco_complete": f"{match.group(1)}%",
            "busco_single": f"{match.group(2)}%",
            "busco_duplicated": f"{match.group(3)}%",
            "busco_fragmented": f"{match.group(4)}%",
            "busco_missing": f"{match.group(5)}%",
            "busco_total": match.group(6),
        }

    results = {}
    for label, key in [("Complete BUSCOs", "busco_complete"), ("Complete and single-copy", "busco_single"),
                        ("Complete and duplicated", "busco_duplicated"), ("Fragmented", "busco_fragmented"),
                        ("Missing", "busco_missing"), ("Total BUSCO", "busco_total")]:
        m = re.search(rf'(\d+)\s+{label}', content)
        results[key] = m.group(1) if m else "N/A"
    return results


def parse_quast_report(assembly):
    report_file = QC_DIR / "quast" / assembly / "report.tsv"
    keys = {"# contigs": "contigs", "Total length": "total_length", "Largest contig": "largest_contig",
            "GC (%)": "gc_percent", "N50": "n50", "N90": "n90", "L50": "l50", "L90": "l90"}
    na = {v: "N/A" for v in keys.values()}
    if not report_file.exists():
        return na

    results = dict(na)
    with open(report_file, 'r') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) >= 2 and parts[0] in keys:
                results[keys[parts[0]]] = parts[1]
    return results


def parse_seqkit_stats(assembly):
    stats_file = QC_DIR / "seqkit" / f"{assembly}_stats.txt"
    if not stats_file.exists():
        return {"num_seqs": "N/A", "sum_len": "N/A", "avg_len": "N/A", "min_len": "N/A", "max_len": "N/A"}

    with open(stats_file, 'r') as f:
        lines = f.readlines()
    if len(lines) < 2:
        return {"num_seqs": "N/A", "sum_len": "N/A", "avg_len": "N/A", "min_len": "N/A", "max_len": "N/A"}

    headers = lines[0].strip().split()
    values = lines[1].strip().split()
    hmap = {h: i for i, h in enumerate(headers)}
    return {
        "num_seqs": values[hmap["num_seqs"]] if "num_seqs" in hmap else "N/A",
        "sum_len": values[hmap["sum_len"]] if "sum_len" in hmap else "N/A",
        "avg_len": values[hmap["avg_len"]] if "avg_len" in hmap else "N/A",
        "min_len": values[hmap["min_len"]] if "min_len" in hmap else "N/A",
        "max_len": values[hmap["max_len"]] if "max_len" in hmap else "N/A",
    }


def main():
    all_results = []
    for assembly in ASSEMBLIES:
        busco = parse_busco_short_summary(assembly)
        quast = parse_quast_report(assembly)
        row = {
            "Assembly": assembly,
            "Contigs": quast["contigs"],
            "Total Length (bp)": quast["total_length"],
            "Largest Contig (bp)": quast["largest_contig"],
            "N50 (bp)": quast["n50"],
            "N90 (bp)": quast["n90"],
            "L50": quast["l50"],
            "L90": quast["l90"],
            "GC (%)": quast["gc_percent"],
            "BUSCO Complete (%)": busco["busco_complete"],
            "BUSCO Single (%)": busco["busco_single"],
            "BUSCO Duplicated (%)": busco["busco_duplicated"],
            "BUSCO Fragmented (%)": busco["busco_fragmented"],
            "BUSCO Missing (%)": busco["busco_missing"],
            "BUSCO Total": busco["busco_total"],
        }
        all_results.append(row)

    fieldnames = list(all_results[0].keys())
    with open(OUTPUT_FILE, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()
        writer.writerows(all_results)

    print(f"Summary written to: {OUTPUT_FILE}")
    print("\n" + "=" * 80)
    print("ASSEMBLY SUMMARY")
    print("=" * 80)
    for row in all_results:
        print(f"\n{row['Assembly'].upper()}")
        print("-" * 40)
        for key, value in row.items():
            if key != "Assembly":
                print(f"  {key}: {value}")


if __name__ == "__main__":
    main()
