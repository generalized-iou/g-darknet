#!/bin/bash
#SBATCH --partition=napoli-gpu --qos=normal
#SBATCH --time=06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=8G

# only use the following on partition with GPU
#SBATCH --cpus-per-task=2
#SBATCH --gres=gpu:1

# Memory per node specification is in MB. It is optional.
# The default limit is 3000MB per core.
#SBATCH --job-name="train"
#SBATCH --output=batch/out/map.out

# only use the following if you want email notification
####SBATCH --mail-user=youremailaddress
####SBATCH --mail-type=ALL

# list out some useful information
echo "SLURM_JOBID="$SLURM_JOBID
echo "SLURM_JOB_NODELIST"=$SLURM_JOB_NODELIST
echo "SLURM_NNODES"=$SLURM_NNODES
echo "SLURMTMPDIR="$SLURMTMPDIR
echo "working directory = "$SLURM_SUBMIT_DIR

# sample job
date;hostname;pwd
python scripts/voc_label_difficult.py --voc_dir datasets/voc/VOCdevkit
LD_LIBRARY_PATH=lib ./darknet detector valid cfg/voc.data cfg/yolov3-voc.cfg backup/baseline2/yolov3-voc.backup
#LD_LIBRARY_PATH=lib ./darknet detector valid cfg/voc.data cfg/yolov3-voc.cfg backups/baseline2/yolov3.weights
python scripts/voc_reval.py --year 2007 --classes data/voc.names --image_set test --voc_dir datasets/voc/VOCdevkit results
echo "Done"
