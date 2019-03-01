#!/bin/bash
# condtionally prepend the APPDIR=$APPDIR config
TMPL=$APPDIR/scripts/crontab.tmpl
NOTE='Configured automatically in darkboard/scripts/setup_cron_paths.sh'
if ! grep -qe "^APPDIR=.*# ${NOTE}$" "$TMPL"; then
  echo -e "APPDIR=${APPDIR}\n$(cat $TMPL) # ${NOTE}" > "$APPDIR/scripts/crontab"
fi
