#!/bin/bash
#SBATCH --partition=dgx,napoli-gpu --qos=normal
#SBATCH --time=7-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=32G

# only use the following on partition with GPU
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:4

# Memory per node specification is in MB. It is optional.
# The default limit is 3000MB per core.
#SBATCH --job-name="yolov3-giou-30"
#SBATCH --output=batch/out/yolov3-giou-30.out

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
#NPROCS=`srun --nodes=${SLURM_NNODES} bash -c 'hostname' |wc -l`
#echo NPROCS=$NPROCS
# can try the following to list out which GPU you have access to
#/usr/local/cuda/samples/1_Utilities/deviceQuery/deviceQuery
LD_LIBRARY_PATH=lib ./darknet detector train cfg/voc.yolov3-giou-30.data cfg/yolov3-voc.yolov3-giou-30.cfg backup/yolov3-giou-30/yolov3-voc.backup -gpus 0,1,2,3
echo "Done"
