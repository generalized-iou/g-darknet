#!/bin/bash
#SBATCH --partition=napoli-gpu --qos=normal
#SBATCH --time=10-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=32G

# only use the following on partition with GPU
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1080ti:2

# Memory per node specification is in MB. It is optional.
# The default limit is 3000MB per core.
#SBATCH --job-name="coco-giou-4"
#SBATCH --output=batch/out/coco-giou-4.out

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

# start with a single
#./darknet detector train cfg/coco.data cfg/yolov3.cfg datasets/voc/darknet53.conv.74

# multipe gpus
#LD_LIBRARY_PATH=lib ./darknet detector train cfg/coco-giou-4.data cfg/yolov3.coco-giou-4.cfg datasets/voc/darknet53.conv.74 > batch/out/coco-giou-4.out
nvidia-smi
#LD_LIBRARY_PATH=lib ./darknet detector train cfg/coco-giou-4.data cfg/yolov3.coco-giou-4.cfg datasets/voc/darknet53.conv.74
LD_LIBRARY_PATH=lib ./darknet detector train cfg/coco-giou-4.data cfg/yolov3.coco-giou-4.cfg backup/coco-giou-4/yolov3_129000.weights -gpus  0,1
echo "Done"
