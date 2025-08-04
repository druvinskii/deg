#!/bin/bash
#SBATCH --job-name=spades
#SBATCH --account=project_2005213
#SBATCH --mem-per-cpu=60G
#SBATCH -t 2-20:00
#SBATCH --partition=small
#SBATCH -c 6 		
#SBATCH -o %j.out			
#SBATCH -e %j.err 	

module load spades

in_dir=
out_dir=

for fastq_file in "$in_dir"/*.fastq; do
  base=$(basename "$fastq_file")
  base=${base%.fastq}
  
  if [ -d "${out_dir}/${base}_spades_output" ]; then
    echo "Output directory for $base already exists, skipping..."
    continue
  fi
  
  spades.py -s "$fastq_file" -o "$out_dir"/"$base"_spades_output -t $SLURM_CPUS_PER_TASK
done

echo "SPAdes assembly completed."
