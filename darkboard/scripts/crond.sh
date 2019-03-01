#!/bin/bash

set -e
set -x

pip install -e $APPDIR/scripts/cocoapi/PythonAPI --user

# put $APPDIR at the top of the cron
./$APPDIR/darkboard/scripts/setup_cron_paths.sh

# copy crontabs for root user
CTAB=/var/spool/cron/crontabs/$UNAME
sudo cp $APPDIR/scripts/crontab $CTAB
sudo chown $UNAME:crontab $CTAB
sudo chmod 600 $CTAB

# start crond with log level 8 in foreground, output to stderr
sudo cron -f
