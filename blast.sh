#!/bin/bash
#SBATCH --job-name=blast
#SBATCH --account=project_2005213
#SBATCH --mem-per-cpu=60G
#SBATCH -t 2-20:00
#SBATCH --partition=small
#SBATCH -c 6 		# number of cores requested -- this needs to be greater than or equal to the number of cores you plan to use to run your job
#SBATCH -o %j.out			# File to which standard out will be written
#SBATCH -e %j.err 		# File to which standard err will be written

module load biokit

# Path to the root directory containing all SPAdes output folders
ROOT_DIR="/scratch/project_2005213/druv/projects/unmapped_wgs/res/contigs"

# Find all contigs.fasta files recursively in the root directory and loop over them
find "$ROOT_DIR" -name "*_contigs.fasta" -type f | while read -r INPUT; do
    
        # Get the name of the directory
    dir_name=$(basename "$INPUT" .fasta)
    
    # Define the output file
    OUTPUT="$ROOT_DIR/${dir_name}_blastn_output.txt"
    
    # Check if the output file already exists
    if [ -f "$OUTPUT" ]; then
        echo "Output file $OUTPUT already exists, skipping..."
        continue
    fi
        
            # Perform the BLASTn alignment
    blastn -query $INPUT -db nt -out $OUTPUT -outfmt '7 qseqid sseqid evalue bitscore sgi sacc sblastnames sskingdoms staxids sscinames scomnames stitle' -max_target_seqs 1
done