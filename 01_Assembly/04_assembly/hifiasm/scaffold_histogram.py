#!/usr/bin/env python3
"""
scaffold_histogram.py — Scaffold size bar plots for a genome assembly.

Usage:
    python3 scaffold_histogram.py <scaffold_sizes.txt> <output_prefix>

Input:
    scaffold_sizes.txt — one integer scaffold/contig length per line
                         (produced by: seqkit fx2tab --name --length asm.fa | awk '{print $2}')

Output:
    <output_prefix>_unlogged.png  — bar plot with linear y-axis
    <output_prefix>_logged.png    — bar plot with log10 y-axis
"""

import sys
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker


def read_sizes(path):
    sizes = []
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if line:
                sizes.append(int(line))
    return sorted(sizes, reverse=True)


def compute_n50(sizes):
    total = sum(sizes)
    cumsum = 0
    for s in sizes:
        cumsum += s
        if cumsum >= total / 2:
            return s
    return sizes[-1]


def draw(sizes, output_prefix, log_y):
    x = np.arange(1, len(sizes) + 1)
    n50 = compute_n50(sizes)
    n50_idx = next(i for i, s in enumerate(sizes) if s <= n50) + 1

    fig, ax = plt.subplots(figsize=(12, 6))

    ax.bar(x, sizes, color="#4C9BE8", linewidth=0, zorder=2)

    # N50 reference line
    ax.axhline(n50, color="#E84C4C", linewidth=1.5, linestyle="--",
               label=f"N50 = {n50:,} bp")

    if log_y:
        ax.set_yscale("log")
        ax.yaxis.set_major_formatter(ticker.FuncFormatter(
            lambda val, _: f"{int(val):,}" if val >= 1 else ""))
        suffix = "logged"
        ylabel = "Contig Size (bp, log₁₀ scale)"
    else:
        ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda val, _: f"{int(val):,}"))
        suffix = "unlogged"
        ylabel = "Contig Size (bp)"

    ax.set_xlabel("Contig", fontsize=12)
    ax.set_ylabel(ylabel, fontsize=12)
    ax.set_title(
        f"Carya aquatica — Primary Assembly Contig Size Distribution\n"
        f"n = {len(sizes):,} contigs | Total = {sum(sizes)/1e6:.2f} Mb | N50 = {n50/1e6:.2f} Mb",
        fontsize=12
    )
    ax.legend(fontsize=10)
    ax.set_xlim(0, len(sizes) + 1)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.5, zorder=1)

    outpath = f"{output_prefix}_{suffix}.png"
    fig.tight_layout()
    fig.savefig(outpath, dpi=200)
    plt.close(fig)
    print(f"Saved: {outpath}")


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)

    sizes_file = sys.argv[1]
    output_prefix = sys.argv[2]

    sizes = read_sizes(sizes_file)
    if not sizes:
        sys.exit("ERROR: no sizes read from input file.")

    draw(sizes, output_prefix, log_y=False)
    draw(sizes, output_prefix, log_y=True)


if __name__ == "__main__":
    main()
