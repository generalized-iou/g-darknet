#!/bin/bash
#SBATCH --partition=napoli-gpu --qos=normal
#SBATCH --time=10-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=42G

# only use the following on partition with GPU
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1080ti:4

# Memory per node specification is in MB. It is optional.
# The default limit is 3000MB per core.
#SBATCH --job-name="coco-baseline4"
#SBATCH --output=batch/out/coco-baseline4.out

# only use the following if you want email notification
#SBATCH --mail-user=tsoi@stanford.edu
#SBATCH --mail-type=ALL

# list out some useful information
echo "SLURM_JOBID="$SLURM_JOBID
echo "SLURM_JOB_NODELIST"=$SLURM_JOB_NODELIST
echo "SLURM_NNODES"=$SLURM_NNODES
echo "SLURMTMPDIR="$SLURMTMPDIR
echo "working directory = "$SLURM_SUBMIT_DIR


# validation
#./darknet detector valid cfg/coco.coco-baseline4.data cfg/yolov3.coco-baseline4.cfg backup/coco-baseline4/yolov3_201119.weights

# sample job
date;hostname;pwd
# start with a single
#LD_LIBRARY_PATH=lib ./darknet detector train cfg/coco.coco-baseline4.data cfg/yolov3.coco-baseline4.cfg datasets/voc/darknet53.conv.74
# multipe gpus
nvidia-smi
LD_LIBRARY_PATH=lib ./darknet detector train cfg/coco.coco-baseline4.data cfg/yolov3.coco-baseline4.cfg backup/coco-baseline4/yolov3.backup -gpus 0,1,2,3
echo "Done"
