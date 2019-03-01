#!/bin/bash
#SBATCH --partition=napoli-gpu --nodelist=napoli108 --qos=normal
#SBATCH --time=06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=2G

# only use the following on partition with GPU
##SBATCH --cpus-per-task=1
##SBATCH --gres=gpu:1

# Memory per node specification is in MB. It is optional.
# The default limit is 3000MB per core.
#SBATCH --job-name="napoli108_setup"
#SBATCH --output=batch/out/napoli108_setup.out

# only use the following if you want email notification
#SBATCH --mail-user=tsoi@stanford.edu
#SBATCH --mail-type=ALL

# list out some useful information
echo "SLURM_JOBID="$SLURM_JOBID
echo "SLURM_JOB_NODELIST"=$SLURM_JOB_NODELIST
echo "SLURM_NNODES"=$SLURM_NNODES
echo "SLURMTMPDIR="$SLURMTMPDIR
echo "working directory = "$SLURM_SUBMIT_DIR

# sample job
date;hostname;pwd
./scripts/local_training_setup.sh
echo "Done"
