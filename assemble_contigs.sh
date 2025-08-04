#!/bin/bash
#SBATCH --job-name=spades
#SBATCH --account=project_2005213
#SBATCH --mem-per-cpu=60G
#SBATCH -t 2-20:00
#SBATCH --partition=small
#SBATCH -c 6 		# number of cores requested -- this needs to be greater than or equal to the number of cores you plan to use to run your job
#SBATCH -o %j.out			# File to which standard out will be written
#SBATCH -e %j.err 		# File to which standard err will be written
module load spades

in_dir="/scratch/project_2005213/druv/projects/unmapped_wgs/res"
out_dir="/scratch/project_2005213/druv/projects/unmapped_wgs/res"


# iterate over .fastq files
for fastq_file in "$in_dir"/*.fastq; do
  base=$(basename "$fastq_file")
  base=${base%.fastq}
  
# Check if the output directory already exists, if so skip this iteration
  if [ -d "${out_dir}/${base}_spades_output" ]; then
    echo "Output directory for $base already exists, skipping..."
    continue
  fi
  
  # Run SPAdes
  spades.py -s "$fastq_file" -o "$out_dir"/"$base"_spades_output -t $SLURM_CPUS_PER_TASK
done

echo "SPAdes assembly completed."