#!/bin/bash
#
#SBATCH --job-name=BMK-ALIGN
#SBATCH --time=00:60:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=16GB
#SBATCH --output=logs/%j.out
#SBATCH --error=logs/%j.err
#SBATCH --account=SC-000098
# Make sure logs dir is created for SLURM logs prior to running

# ASSUME source "pipelinefunc.sh;get_ena;download" has been run already and src dir exists
# ASSUME qc has been run already
source pipelinefunc.sh
align
