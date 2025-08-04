This is a collection of scripts for a pipeline that allows to align unmapped reads to a blast database, generate kmers from these contigs as well as generate PCA data.

BAM files are 1. concatenated; 2. assembled into contigs; 3. aligned; and 4. BLASTed.

large_kmers.py - This is a python script that allows to generate fasta,npz and csv files of kmers from read files. This script allows for the generation of large kmer sizes due to the utilisaiton of a sparse matrix. 
pca.py - performs principal component analysis
