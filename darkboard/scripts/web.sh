#!/bin/bash

set -e
set -x

#echo uid: $UID
#echo gid: $GID
#echo who i am: $(whoami)

# rails deps
cd $APPDIR/darkboard && bundle install
cd $APPDIR/darkboard && bundle exec rails db:migrate RAILS_ENV=development

# logs
LOG_RAILS=$APPDIR/darkboard/log/rails.log
LOG_ANGULAR=$APPDIR/darkboard/log/angular.log
LOG_CRON=$APPDIR/darkboard/log/cron.log

# lids
PID_RAILS=/tmp/rails.pid

# angular deps
cd $APPDIR/darkboard/client && yarn install

# Start rails
rm -rf $PID_RAILS
cd $APPDIR/darkboard && nohup bundle exec rails s --pid $PID_RAILS 2>&1 | tee -a $LOG_RAILS &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start rails server: $status" | tee -a $LOG_RAILS
  exit $status
fi

# Start angular
cd $APPDIR/darkboard/client && nohup yarn start 2>&1 | tee -a $LOG_ANGULAR &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start angular server: $status" | tee -a $LOG_ANGULAR
  exit $status
fi

# Start a cron to update charts
nohup crond -f 2>&1 | tee -a $LOG_CRON &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start crond: $status" | tee -a $LOG_CRON
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

# Be less verbose now
set +x
while sleep 60; do
  ps aux | grep $(cat /tmp/rails.pid)| grep -q -v grep
  RAILS_STATUS=$?
  ps aux | grep 'ng' | grep -q -v grep
  ANGULAR_STATUS=$?
  ps aux | grep cron | grep -q -v grep
  CROND_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $RAILS_STATUS -ne 0 ]; then
    echo "The rails processes has already exited." | tee -a $LOG_RAILS
    sleep 2;
    exit 1
  fi
  if [ $ANGULAR_STATUS -ne 0 ]; then
    echo "The angular processes has already exited." | tee -a $LOG_ANGULAR
    sleep 2;
    exit 1
  fi
  if [ $CROND_STATUS -ne 0 ]; then
    echo "The crond processes has already exited." | tee -a $LOG_CRON
    sleep 2;
    exit 1
  fi
done
