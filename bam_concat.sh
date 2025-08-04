#!/bin/bash
#SBATCH --job-name=samtools
#SBATCH --account=project_2005213
#SBATCH --mem-per-cpu=30G
#SBATCH -t 0-5:00
#SBATCH --partition=small
#SBATCH -c 6 		
#SBATCH -o %j.out		
#SBATCH -e %j.err 		



module load samtools/1.16.1



dir=
out_dir=

mkdir -p "$out_dir"
declare -A output_files

while IFS=$'\t' read -r animal filename
do
 
  if [ -e "${out_dir}/${filename}.bam" ]; then
    echo "Output file for $filename already exists, skipping..."
    continue
  fi
  
  mapfiles=($(find "$dir" -type f -name "*${animal}*.bam"))

  for file in "${mapfiles[@]}"; do
    output_files[$filename]+="$file "
    echo "Added $file to the list for $filename"
  done
done < names.txt

for filename in "${!output_files[@]}"; do
  echo "Merging files for $filename"
  samtools merge -f "${out_dir}/${filename}.bam" ${output_files[$filename]}
  echo "Completed merging files for $filename"
done
