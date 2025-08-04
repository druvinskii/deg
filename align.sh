#!/bin/bash

# Path to the root directory containing all SPAdes output folders
ROOT_DIR="/scratch/project_2005213/druv/projects/unmapped_wgs/res"

# Directory to store SLURM scripts
SCRIPT_DIR="/scratch/project_2005213/druv/projects/unmapped_wgs/scripts"

# File to store the list of 'contigs.fasta' files
FILE_LIST="$SCRIPT_DIR/contigs.txt"

# Find all contigs.fasta files recursively in the root directory and store them in the file
find "$ROOT_DIR" -name "contigs.fasta" -type f > "$FILE_LIST"

# Count the number of files
NUM_FILES=$(wc -l < "$FILE_LIST")

# Create a SLURM script for the array job
SCRIPT="$SCRIPT_DIR/blastn_array_job.slurm"

cat > "$SCRIPT" <<EOF
#!/bin/bash


#SBATCH --account=project_2005213
#SBATCH --mem-per-cpu=60G
#SBATCH -t 2-20:00
#SBATCH --partition=large
#SBATCH -c 6 		# number of cores requested -- this needs to be greater than or equal to the number of cores you plan to use to run your job
#SBATCH -o %j.out			# File to which standard out will be written
#SBATCH -e %j.err 		# File to which standard err will be written
#SBATCH --job-name=blastn_array_job
#SBATCH --output=${SCRIPT_DIR}/blastn_array_job_%A_%a.out
#SBATCH --error=${SCRIPT_DIR}/blastn_array_job_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --array=1-$NUM_FILES

module load biokit

# Get the file name from the list
INPUT=$(sed -n \${SLURM_ARRAY_TASK_ID}p $FILE_LIST)

# Get the directory of the current file
dir=$(dirname "$INPUT")

# Get the name of the directory
dir_name=$(basename "$dir")

# Define the output file
OUTPUT="/scratch/project_2005213/druv/projects/unmapped_wgs/res/align/${dir_name}_blastn_output.txt"

blastn -query $INPUT -db nt -out $OUTPUT -outfmt '7 qseqid sseqid evalue bitscore sgi sacc sblastnames sskingdoms staxids sscinames scomnames stitle' -max_target_seqs 1
EOF

# Submit the job
sbatch "$SCRIPT"
