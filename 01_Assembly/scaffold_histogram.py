import matplotlib.pyplot as plt
import numpy as np
import argparse

def read_scaffold_sizes(file_path):
    """Read scaffold sizes from a file and return a sorted list."""
    scaffold_sizes = []
    with open(file_path, 'r') as f:
        for line in f:
            size = int(line.strip())
            scaffold_sizes.append(size)
    return sorted(scaffold_sizes, reverse=True)

def plot_scaffold_histogram(scaffold_sizes, output_prefix):
    """Plot scaffold size histogram with logged and unlogged y-axis."""
    x = np.arange(1, len(scaffold_sizes) + 1)

    # Unlogged y-axis
    plt.figure(figsize=(10, 6))
    plt.bar(x, scaffold_sizes, color='skyblue')
    plt.xlabel('Scaffold Number (sorted)')
    plt.ylabel('Scaffold Size (bp)')
    plt.title('Scaffold Size Distribution (Unlogged)')
    plt.savefig(f"{output_prefix}_unlogged.png")
    plt.close()

    # Logged y-axis
    plt.figure(figsize=(10, 6))
    plt.bar(x, scaffold_sizes, color='skyblue')
    plt.yscale('log')
    plt.xlabel('Scaffold Number (sorted)')
    plt.ylabel('Scaffold Size (bp, log scale)')
    plt.title('Scaffold Size Distribution (Logged)')
    plt.savefig(f"{output_prefix}_logged.png")
    plt.close()

def main():
    parser = argparse.ArgumentParser(description='Generate scaffold size histograms.')
    parser.add_argument('input_file', help='Path to the file containing scaffold sizes (one size per line).')
    parser.add_argument('output_prefix', help='Prefix for the output histogram files.')
    args = parser.parse_args()

    scaffold_sizes = read_scaffold_sizes(args.input_file)
    plot_scaffold_histogram(scaffold_sizes, args.output_prefix)

if __name__ == "__main__":
    main()