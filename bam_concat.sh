#!/bin/bash
#SBATCH --job-name=samtools
#SBATCH --account=project_2005213
#SBATCH --mem-per-cpu=30G
#SBATCH -t 0-5:00
#SBATCH --partition=small
#SBATCH -c 6 		# number of cores requested -- this needs to be greater than or equal to the number of cores you plan to use to run your job
#SBATCH -o %j.out			# File to which standard out will be written
#SBATCH -e %j.err 		# File to which standard err will be written



module load samtools/1.16.1


# Directory containing the .bam files
dir="/scratch/project_2005213/druv/projects/unmapped_wgs/raw"

# Directory where the output .bam files should be saved
out_dir="/scratch/project_2005213/druv/projects/unmapped_wgs/res"

# Make sure the output directory exists
mkdir -p "$out_dir"

# Declare an associative array to keep track of BAM files for each output file
declare -A output_files

# Read the input file line by line
while IFS=$'\t' read -r animal filename
do
  # Check if the output BAM file already exists, if so skip this iteration
  if [ -e "${out_dir}/${filename}.bam" ]; then
    echo "Output file for $filename already exists, skipping..."
    continue
  fi
  
  # Find .bam files that contain the animal name and store them in an array
  mapfiles=($(find "$dir" -type f -name "*${animal}*.bam"))

  # Add each BAM file to the list of files to be merged into the corresponding output file
  for file in "${mapfiles[@]}"; do
    output_files[$filename]+="$file "
    echo "Added $file to the list for $filename"
  done
done < names.txt

# Merge the BAM files for each output file
for filename in "${!output_files[@]}"; do
  echo "Merging files for $filename"
  samtools merge -f "${out_dir}/${filename}.bam" ${output_files[$filename]}
  echo "Completed merging files for $filename"
done