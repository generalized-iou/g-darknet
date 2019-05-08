# GDarknet

YoloV3 with GIoU loss implemented in Darknet

If you use this work, please consider citing:

```
@article{Rezatofighi_2018_CVPR,
  author    = {Rezatofighi, Hamid and Tsoi, Nathan and Gwak, JunYoung and Sadeghian, Amir and Reid, Ian and Savarese, Silvio},
  title     = {Generalized Intersection over Union},
  booktitle = {The IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
  month     = {June},
  year      = {2019},
}
```

## Modifications in this repository

This repository contains a YoloV3 implementation of the GIoU loss (and IoU loss) while keeping the code as close to the original as possible. It is also possible to train with MSE loss as well, see the options below. We have only made changes intended for use with YoloV3 and to that end, no networks other than YoloV3 have been intentionally modified or tested.

### Losses

The loss can be chosen with the `iou_loss` option in the `.cfg` file and must be specified on each `[yolo]` layer. The valid options are currently: `[iou|giou|mse]`

```
iou_loss=mse
```

### Normalizers

We also implement a normalizer between the localization and classification loss. These can be specified with the `cls_normalizer` and `iou_normalizer` parameters on the `[yolo]` layers. The default values are `1.0` for both. In our constrained search, the following values appear to work well for the `GIoU` loss.

```
cls_normalizer=1
iou_normalizer=0.5
```

### Representations

Though not currently tested in the paper above, we have begun to experiment with different representations (removing the exponential). These can be specified with the `representation` option on each `[yolo]` layer. Valid options are `[lin|exp]` and the default value is `exp`.

### Data

#### Augmentation

It has been reported that the custom data augmentation code in the original [Darknet repository](https://github.com/pjreddie/darknet) is a significant bottleneck during training. To this end, we have replaced the data loading and augmentation with the OpenCV implementation in [AlexeyAB's fork](https://github.com/AlexeyAB/darknet).

#### Output Prefix

To enable multiple simultaneous runs of the network, we have added a parameter named `prefix` to the `.data` config file.

This parameter should be set to your run name and will be used in the appropriate places to separate output by prefix per running instance.

## Scripts

A description of the scripts contained in this repository follows.

### Data pre-processing

see: `scripts/get_2017_coco_dataset.sh`

### Evaluation

See `scripts/voc_all_map.py` for VOC evaluation and  `scripts/coco_all_map.py` for COCO evaluation and `scripts/crontab.tmpl` for usage

### sbatch

At Stanford, we use Slurm to manage the shared resources in our computing clusters

The [batch] directory contains the `sbatch` launch scripts for our cluster. Each script contain the bash commands used to start the network for a given test run.

## Visualization

We have created a visualization tool, named Darkboard, to plot data generated during training. Though the implementation was quick and dirty, this tool is useful in evaluating network performance.

Details on running Darkboard can be found in the [/darkboard/README.md]() file.

## Pre-trained Models

See the [Workflow](#workflow) and [Evaluation](#evaluation) sections below for details on how to use these files

|Link|Dataset|Loss|Save as local file|cfg used for training|
|--|--|--|--|--|
|https://stanford.io/2Hb6hpz|coco|mse|backup/coco-baseline4/yolov3_492000.weights|cfg/runs/coco-baseline4/yolov3.coco-baseline4.cfg|
|https://stanford.io/307a4LO|coco|iou|backup/coco-iou-14/yolov3_470000.weights|cfg/runs/coco-iou-14/yolov3.coco-iou-14.cfg|
|https://stanford.io/2PWP8Cz|coco|giou|backup/coco-giou-12/yolov3_final.weights|cfg/runs/coco-giou-12/yolov3.coco-giou-12.cfg|
|https://stanford.io/2vNjsGC|voc|mse|backup/yolov3-baseline2/yolov3-voc_50000.weights|cfg/runs/yolov3-baseline2/yolov3-voc.yolov3-baseline2.cfg|
|https://stanford.io/2WyedWT|voc|iou|backup/yolov3-giou-30/yolov3-voc_48000.weights|cfg/runs/yolov3-giou-30/yolov3-voc.yolov3-giou-30.cfg|
|https://stanford.io/2Hb70Hj|voc|giou|backup/yolov3-giou-40/yolov3-voc_50000.weights|cfg/runs/yolov3-giou-40/yolov3-voc.yolov3-giou-40.cfg|

Or download them all with:

```
mkdir backup && cd backup
mkdir coco-baseline4 && cd coco-baseline4 && curl -O https://stanford.io/2Hb6hpz && cd ..
mkdir coco-iou-14 && cd coco-iou-14 && curl -O https://stanford.io/307a4LO && cd ..
mkdir coco-giou-12 && cd coco-giou-12 && curl -O https://stanford.io/2PWP8Cz && cd ..
mkdir yolov3-baseline2 && cd yolov3-baseline2 && curl -O https://stanford.io/2vNjsGC && cd ..
mkdir yolov3-giou-30 && cd yolov3-giou-30 && curl -O https://stanford.io/2WyedWT && cd ..
mkdir yolov3-giou-40 && cd yolov3-giou-40 && curl -O https://stanford.io/2Hb70Hj && cd ..
cd ..
```

## Workflow

When training the network I used several workstations and servers, each with one or more GPUs, all attached to a shared network drive. Using this network drive is convenient for sharing code and weight files, however for performance reasons, training and inference data should be loaded from a local disk.

To make running on various machines easier, I use the `scripts/package_libs.sh` script to pull all dependencies of darknet and place them in a single folder (`lib`).

For each test run I create the following new files:

|file name|purpose|
|---|---|
|cfg/[run name].data|data sources for train and validation data as well as the run prefix setting (which, by convention I always to [run name])|
|cfg/[run name].cfg|network configuration including loss, normalizers and representation|
|batch/[run name].sbatch|slurm sbatch configuration for this test including number of GPUs|

Note that the `cfg/[run name].cfg` file contains parameters that must be changed when changing the number of GPUs used for training.

Note that these files at one point all existed in the `cfg/` folder, but have been separated by test name into the `cfg/runs/` folder, so the paths below may not accurately reflect how to run the tests. Simply add the necessary path prefix to the config files.

To run one instance of the network, I run, where `[run name]` has been set to `openimages-giou-1`:

```
LD_LIBRARY_PATH=lib ./darknet detector train cfg/openimages-giou-1.data cfg/openimages-giou-1.cfg datasets/voc/darknet53.conv.74
```

I always start with the pretrained `darknet53.conv.74` weights and train on a single GPU to at least 1K iterations.

After this, I change `cfg/[run name].cfg`, decreasing the `learning_rate` by setting `NEW_RATE = ORIGINAL_RATE * 1/NUMBER_OF_GPUS` and increasing the `burn_in` setting it to `NEW_BURN_IN = ORIGINAL_BURN_IN * NUMBER_OF_GPUS`

So for one GPU, the relevant portion of the `.cfg` file would be:

    learning_rate=0.001
    burn_in=1000

And for two GPUs, the relevant portion of the `.cfg` file would be:

    learning_rate=0.0005
    burn_in=2000

And for four GPUs, the relevant portion of the `.cfg` file would be:

    learning_rate=0.00025
    burn_in=4000

Then, resume the run from a specific iteration's weight file or in the case below, the backup, passing in the GPUs to run with using:

```
LD_LIBRARY_PATH=lib ./darknet detector train cfg/openimages-giou-1.data cfg/openimages-giou-1.cfg backup/coco-giou-13/openimages-giou-1.backup -gpus 0,1,2,3
```

## Configuring the network

Before running the network a variety of options must be selected:

  - Data
    - Path to datasets
    - Training and Validation datasets

Or copy from an existing config with the `build_run.sh` tool:

### Config creation tool

To copy an existing config to a new config, use:

    ./scripts/build_run.sh yolov3-voc-lin-7 yolov3-voc-lin-8

Then run with

    sbatch cfg/runs/yolov3-voc-lin-8/run.sbatch

## Evaluation

This repository contains tools for running ongoing evaluation while training the network.

### VOC

Evaluate all weights files in the given `weights_folder` with both the IoU and GIoU metrics using the following script:

    python scripts/voc_all_map.py --data_file cfg/yolov3-voc-lin-1.data --cfg_file cfg/yolov3-voc-lin-1.cfg --weights_folder backup/yolov3-voc-lin-1/

MSE Loss on IoU Metric

    mkdir -p results/voc-baseline2 && ./darknet detector valid cfg/runs/yolov3-baseline2/voc.yolov3-baseline2.data cfg/runs/yolov3-baseline2/yolov3-voc.yolov3-baseline2.cfg backup/yolov3-baseline2/yolov3-voc_50000.weights -i 0 -prefix results/voc-baseline2
    python scripts/voc_reval.py results/voc-baseline2

Will show:

    Threshold: 0.50 | mAP: 0.759
    Threshold: 0.55 | mAP: 0.736
    Threshold: 0.60 | mAP: 0.704
    Threshold: 0.65 | mAP: 0.658
    Threshold: 0.70 | mAP: 0.579
    Threshold: 0.75 | mAP: 0.486
    Threshold: 0.80 | mAP: 0.356
    Threshold: 0.85 | mAP: 0.219
    Threshold: 0.90 | mAP: 0.093
    Threshold: 0.95 | mAP: 0.022
    mAP: 0.461139307176

To evaluate on the GIoU Metric, run:

    python scripts/voc_reval.py results/voc-baseline2 --giou_metric

Which yields:

    Threshold: 0.50 | mAP: 0.752
    Threshold: 0.55 | mAP: 0.725
    Threshold: 0.60 | mAP: 0.690
    Threshold: 0.65 | mAP: 0.639
    Threshold: 0.70 | mAP: 0.566
    Threshold: 0.75 | mAP: 0.467
    Threshold: 0.80 | mAP: 0.345
    Threshold: 0.85 | mAP: 0.209
    Threshold: 0.90 | mAP: 0.092
    Threshold: 0.95 | mAP: 0.022
    mAP: 0.450614109869

IOU Loss

    mkdir -p results/voc-giou-30 && ./darknet detector valid cfg/runs/yolov3-giou-30/voc.yolov3-giou-30.data cfg/runs/yolov3-giou-30/yolov3-voc.yolov3-giou-30.cfg backup/yolov3-giou-30/yolov3-voc_48000.weights -i 0 -prefix results/voc-giou-30
    # IoU Metric Eval
    python scripts/voc_reval.py results/voc-giou-30
    # GIoU Metric Eval
    python scripts/voc_reval.py results/voc-giou-30 --giou_metric

GIOU Loss

    mkdir -p results/voc-giou-40 && ./darknet detector valid cfg/runs/yolov3-giou-40/voc.yolov3-giou-40.data cfg/runs/yolov3-giou-40/yolov3-voc.yolov3-giou-40.cfg backup/yolov3-giou-40/yolov3-voc_51000.weights -i 0 -prefix results/voc-giou-40
    # IoU Metric Eval
    python scripts/voc_reval.py results/voc-giou-40
    # GIoU Metric Eval
    python scripts/voc_reval.py results/voc-giou-40 --giou_metric

### COCO

Evaluate all weights files in the given `weights_folder` with both the IoU and GIoU metrics using the following script:

    python scripts/coco_all_map.py --data_file cfg/coco-giou-12.data --cfg_file cfg/yolov3.coco-giou-12.cfg --weights_folder backup/coco-giou-12 --lib_folder lib --gpu_id 0 --min_weight_id 20000

See the [crontab.tmpl](scripts/crontab.tmpl) file for details

Evaluate a specific weights file:

    mkdir -p results/coco-giou-12 && ./darknet detector valid cfg/runs/coco-giou-12/coco-giou-12.data cfg/runs/coco-giou-12/yolov3.coco-giou-12.cfg backup/coco-giou-12/yolov3_final.weights -i 0 -prefix results/coco-giou-12

The detector results are written to `coco_results.json` in the prefix specified above

Now edit `scripts/coco_eval.py` to load the this resulting json file and run the evaluation script:

```
> python scripts/coco_eval.py
Running demo for *bbox* results.
loading gt datasets/coco/coco/annotations/instances_minival2014.json
loading annotations into memory...
Done (t=4.76s)
creating index...
index created!
loading predicted results/coco-giou-12/coco_results.json
Loading and preparing results...
DONE (t=3.04s)
creating index...
index created!
Running per image evaluation...
Evaluate annotation type *bbox*
DONE (t=30.54s).
Accumulating evaluation results...
DONE (t=3.97s).
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.335
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.533
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.359
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.167
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.360
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.452
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.294
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.459
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.486
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.293
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.520
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.619
```

Or, for example, check the baseline:

    mkdir -p results/coco-baseline-4 && ./darknet detector valid cfg/runs/coco-baseline4/coco.coco-baseline4.data cfg/runs/coco-baseline4/yolov3.coco-baseline4.cfg backup/coco-baseline4/yolov3_492000.weights -i 0 -prefix results/coco-baseline-4

After editing `scripts/coco_eval.py` to load the this resulting json file and run the evaluation script:

```
> python scripts/coco_eval.py
Running demo for *bbox* results.
loading gt datasets/coco/coco/annotations/instances_minival2014.json
loading annotations into memory...
Done (t=4.76s)
creating index...
index created!
loading predicted results/coco-baseline-4/coco_results.json
Loading and preparing results...
DONE (t=3.05s)
creating index...
index created!
Running per image evaluation...
Evaluate annotation type *bbox*
DONE (t=27.54s).
Accumulating evaluation results...
DONE (t=3.31s).
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.314
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.534
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.329
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.153
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.340
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.426
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.282
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.427
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.446
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.272
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.474
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.590
```

Note that the above examples evalute on the IoU metric only, use the `scripts/coco_all_map.py` script to evaulate on the GIoU metric as well.

### Ongoing Evaluation

The easiest way I have found to keep the evaluations up to date is to run the following via cron on some interval (preferably on a GPU other than those used for training)

    */10 * * * * cd $HOME/src/nn/darknet && flock -n /tmp/coco-iou-15.lockfile -c 'python scripts/coco_all_map.py --data_file cfg/coco-iou-15.data --cfg_file cfg/yolov3.coco-iou-15.cfg --weights_folder backup/coco-iou-15 --lib_folder lib --gpu_id 0' > $HOME/src/nn/darknet/batch/out/coco-iou-15.map.out 2>&1


## TODOs

The described setup requires a shared file system when training and testing across multiple machines. In the absence of this, it would be useful to have some logging service to aggregate logs over a network protocol vs requiring a write to shared disk.

## Acknowledgments

Thank you to the Darknet community for help getting started on this code. Specifically, thanks to [AlexeyAB](https://github.com/AlexeyAB/) for his fork of [Darknet](https://github.com/AlexeyAB/darknet), which has been useful as a reference for understanding the code.



## Original Readme

![Darknet Logo](http://pjreddie.com/media/files/darknet-black-small.png)

# Darknet #
Darknet is an open source neural network framework written in C and CUDA. It is fast, easy to install, and supports CPU and GPU computation.

For more information see the [Darknet project website](http://pjreddie.com/darknet).

For questions or issues please use the [Google Group](https://groups.google.com/forum/#!forum/darknet).
