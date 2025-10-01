#!/bin/bash
# File writing the necessary cronjobs
base_dir="$HOME"

cron_schedule_restart="0 0 * * 0"
restart_command="/sbin/shutdown -r"

cron_deletion_schedule="30 * * * *"
cron_deletion_raw="find /data/eprofile-mwr-l1/ -mmin +2880 -type f -delete"
log_file_deletion="$base_dir/deleted.txt"

# Write the cron jobs to a temporary file
echo "$cron_schedule_restart $restart_command" > mycron
echo "$cron_deletion_schedule $cron_deletion_raw >> $log_file_deletion 2>&1" >> mycron

# Install the new cron jobs from the temporary file -> needs to be root for restart !
# sudo crontab mycron
# Instead of installing the cron directly, output indication on how to do it:
echo "cron can now be installed running: sudo crontab mycron"