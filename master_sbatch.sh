#!/bin/bash
#
# Get the input datasets
source pipelinefunc.sh;get_ena;download

# For SLURM logs
mkdir -p logs

# Submit jobs with dependencies
jid1=$(sbatch --parsable qc_sbatch.sh)
jid2=$(sbatch --dependency=afterany:$jid1 --parsable align_sbatch.sh)
jid3=$(sbatch --dependency=afterany:$jid2 --parsable callvariants_sbatch.sh)

# Show job dependencies in queue
squeue -u $USER -o "%.8A %.4C %.10m %.20E"
