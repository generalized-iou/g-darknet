# Dataset

    mkdir -p datasets/voc && cd datasets/voc
    wget https://pjreddie.com/media/files/VOCtrainval_11-May-2012.tar
    wget https://pjreddie.com/media/files/VOCtrainval_06-Nov-2007.tar
    wget https://pjreddie.com/media/files/VOCtest_06-Nov-2007.tar
    tar xf VOCtrainval_11-May-2012.tar
    tar xf VOCtrainval_06-Nov-2007.tar
    tar xf VOCtest_06-Nov-2007.tar

# Labels

    cd datasets/voc
    python ../../scripts/voc_label.py

# Training File

Generate a file with all but the 2007 test data

    cd datasets/voc
    cat 2007_train.txt 2007_val.txt 2012_*.txt > train.txt

# Pretrained weights from imagenet

"For training we use convolutional weights that are pre-trained on Imagenet. We use weights from the darknet53 model. You can just download the weights for the convolutional layers here (76 MB)."

    cd datasets/voc
    wget https://pjreddie.com/media/files/darknet53.conv.74

# Config

in `cfg/voc.data`, modify:

    classes = 20
    train  = datasets/voc/train.txt
    valid  = datasets/voc/2007_test.txt
    names  = data/voc.names
    backup = backup

# Train

Apply patch for training:

    diff --git a/cfg/yolov3-voc.cfg b/cfg/yolov3-voc.cfg
    index 3f3e8df..3ad2659 100644
    --- a/cfg/yolov3-voc.cfg
    +++ b/cfg/yolov3-voc.cfg
    @@ -1,10 +1,10 @@
     [net]
     # Testing
    - batch=1
    - subdivisions=1
    +# batch=1
    +# subdivisions=1
     # Training
    -# batch=64
    -# subdivisions=16
    + batch=64
    + subdivisions=16
     width=416
     height=416
     channels=3

Set backup prefix in `cfg/voc.data` (`prefix` value)

Train

    ./darknet detector train cfg/voc.data cfg/yolov3-voc.cfg datasets/voc/darknet53.conv.74

Or, restart with

Where `backup/capri24/yolov3-voc_900.weights` is your last backup (will include prefix value, if set):

    ./darknet detector train cfg/voc.data cfg/yolov3-voc.cfg backup/capri24/yolov3-voc_900.weights

Or, via slurm (on sc.stanford.edu):

    sbatch batch/train.sbatch; tail -f batch/out/train.out

# Plots via Webserver

See `darkboard/readme.md`

Browse to: http://localhost:4200

# Test mAP

    REVERT THE ABOVE PATCH TO `cfg/yolov3-voc.cfg`, restoring the settings for testing 

    python scripts/voc_label_difficult.py --voc_dir datasets/voc/VOCdevkit

    ./darknet detector valid cfg/voc.data cfg/yolov3-voc.cfg yolov3-voc_final.weights

    python scripts/voc_reval.py --year 2007 --classes data/voc.names --image_set test --voc_dir datasets/voc/VOCdevkit results

- or, compute mAP from .5 to .95 IoU with

    python scripts/voc_all_map.py --weights_folder backup/yolov3-giou-25/ --metric iou


Or, via slurm (on sc.stanford.edu):

    sbatch batch/map.sbatch; tail -f batch/out/map.out
