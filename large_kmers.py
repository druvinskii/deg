import os
import sys
import numpy as np
from scipy.sparse import load_npz
from Bio import SeqIO
from collections import Counter
import pandas as pd

# set kmer size
k = 12  


fasta = sys.argv[1]
npz = sys.argv[2]
output_dir = sys.argv[3]

os.makedirs(output_dir, exist_ok=True)

# kmer generation. We generate indices where each kmer starts within sequence, obtain total length of sequence, 
# and then ensure that the range stops to so that the final kmer has exactly k bases.
def generate_kmers(sequence, k):
    return [sequence[i:i + k] for i in range(len(sequence) - k + 1)]

# Reconstruct filtered k-mers
def reconstruct_kmers(fasta, k, min_frequency=10):
    all_kmers = Counter()
    for record in SeqIO.parse(fasta, "fasta"):
        if len(record.seq) < k:
            continue  # script MUST skip sequences shorter than k
        kmers = generate_kmers(str(record.seq), k)
        all_kmers.update(kmers)
    filtered_kmers = {kmer for kmer, count in all_kmers.items() if count >= min_frequency}
    return filtered_kmers

# Map k-mers to sparse matrix to save memory. The zero values can really eat into that- remove them.
def map_kmers_matrix(npz, filtered_kmers):
    # Load the sparse matrix
    sparse_matrix = load_npz(npz)
    print(f"Sparse matrix shape: {sparse_matrix.shape}")

    # k-mers that match the number of columns in the sparse matrix
    filtered_kmers = list(filtered_kmers)[:sparse_matrix.shape[1]]
    print(f"Number of k-mers after matching to matrix columns: {len(filtered_kmers)}")

    # Map column indices to k-mers
    index_to_kmer = {idx: kmer for idx, kmer in enumerate(filtered_kmers)}
    return sparse_matrix, index_to_kmer

# Save reconstructed k-mers to FASTA
def save_kmers_fasta(index_to_kmer, output_file):
    with open(output_file, "w") as f:
        for idx, kmer in index_to_kmer.items():
            f.write(f">kmer_{idx}\n{kmer}\n")

# Main workflow
print(f"Processing {fasta} and {npz}")
filtered_kmers = reconstruct_kmers(fasta, k)
print(f"Filtered k-mers: {len(filtered_kmers)}")

sparse_matrix, index_to_kmer = map_kmers_matrix(npz, filtered_kmers)

# Save reconstructed k-mers in fasta format
fasta_output = os.path.join(output_dir, f"{os.path.basename(fasta).split('_spades')[0]}_reconstructed_kmers.fasta")
save_kmers_fasta(index_to_kmer, fasta_output)

# Save sparse matrix as CSV 
matrix_df = pd.DataFrame.sparse.from_spmatrix(sparse_matrix, columns=filtered_kmers)
matrix_csv_output = os.path.join(output_dir, f"{os.path.basename(fasta).split('_spades')[0]}_kmer_matrix.csv")
matrix_df.to_csv(matrix_csv_output, index=False)

print(f"Processed files saved to {output_dir}")
