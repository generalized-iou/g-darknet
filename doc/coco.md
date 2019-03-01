# Dataset

    COCODIR=datasets/coco/
    mkdir -p $COCODIR
    cp scripts/get_coco_dataset.sh $COCODIR
    pushd $COCODIR
    get_coco_dataset.sh
    popd

# Download Weights

curl https://pjreddie.com/media/files/yolov3.weights -o datasets/pretrained/yolov3-608.weights

# Single image test

./darknet detector test cfg/coco.data cfg/yolov3.cfg datasets/pretrained/yolov3-608.weights data/dog.jpg

# Evaluation

## Setup
    push scripts
    pip2 install Cython --user
    pip2 install -e 'git+https://github.com/ahundt/cocoapi.git#egg=pycocotools&subdirectory=PythonAPI' --user
    popd

# mAP

    ./darknet detector valid cfg/coco.data cfg/yolov3.cfg datasets/pretrained/yolov3-608.weights
    #writes to: results/coco_results.json

    python scripts/coco_eval.py

