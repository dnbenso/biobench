#!/bin/bash
#
#SBATCH --job-name=BMK-QC
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem=4GB
#SBATCH --output=logs/%j.out
#SBATCH --error=logs/%j.err
#SBATCH --account=SC-000098
# Make sure logs dir is created for SLURM logs prior to running

# ASSUME "source pipelinefunc.sh;get_ena;download" has been run already and src dir exists
source pipelinefunc.sh
qc
