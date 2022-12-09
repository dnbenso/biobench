#!/bin/bash
#
# Get the input datasets
source pipelinefunc.sh;get_ena;download

# For SLURM logs
mkdir logs

# Submit jobs with dependencies
jid1=$(sbatch qc_sbatch.sh)
jid2=$(sbatch  --dependency=afterany:$jid1 align_sbatch.sh)
jid3=$(sbatch  --dependency=afterany:$jid2 callvariants_sbatch.sh)

squeue -u $USER -o "%.8A %.4C %.10m %.20E"
