#!/bin/bash

# Computes mAP

set -o nounset  # exit if trying to use an uninitialized var
set -o errexit  # exit if any program fails
set -o pipefail # exit if any program in a pipeline fails, also
set -x          # debug mode

# This file's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# project root
RUN_PATH="$( cd $DIR/.. >/dev/null && pwd )"

pushd $RUN_PATH
python scripts/voc_all_map.py --data_file cfg/runs/yolov3-voc-lin-8/data --cfg_file cfg/runs/yolov3-voc-lin-8/cfg --weights_folder backup/yolov3-voc-lin-8/ --lib_folder lib
popd
