#!/bin/bash
#SBATCH --job-name=blast
#SBATCH --account=project_2005213
#SBATCH --mem-per-cpu=60G
#SBATCH -t 2-20:00
#SBATCH --partition=small
#SBATCH -c 6 		
#SBATCH -o %j.out			
#SBATCH -e %j.err 		

module load biokit


ROOT_DIR=


find "$ROOT_DIR" -name "*_contigs.fasta" -type f | while read -r INPUT; do
    
        
    dir_name=$(basename "$INPUT" .fasta)
    
 
    OUTPUT="$ROOT_DIR/${dir_name}_blastn_output.txt"
    
   
    if [ -f "$OUTPUT" ]; then
        echo "Output file $OUTPUT already exists, skipping..."
        continue
    fi
        
          
    blastn -query $INPUT -db nt -out $OUTPUT -outfmt '7 qseqid sseqid evalue bitscore sgi sacc sblastnames sskingdoms staxids sscinames scomnames stitle' -max_target_seqs 1
done
