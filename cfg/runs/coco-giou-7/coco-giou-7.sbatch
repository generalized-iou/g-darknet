#!/bin/bash
#SBATCH --partition=dgx --qos=normal
#SBATCH --time=7-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=32G

# only use the following on partition with GPU
#SBATCH --cpus-per-task=2
#SBATCH --gres=gpu:4

# Memory per node specification is in MB. It is optional.
# The default limit is 3000MB per core.
#SBATCH --job-name="coco-giou-7"
#SBATCH --output=batch/out/coco-giou-7.out

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
# start with a single
#LD_LIBRARY_PATH=lib ./darknet detector train cfg/coco-giou-7.data cfg/yolov3.coco-giou-7.cfg datasets/voc/darknet53.conv.74
# multipe gpus
LD_LIBRARY_PATH=lib ./darknet detector train cfg/coco-giou-7.data cfg/yolov3.coco-giou-7.cfg backup/coco-giou-7/yolov3_167000.weights -gpus 0,1,2,3
echo "Done"

