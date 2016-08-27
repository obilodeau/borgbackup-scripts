#!/bin/sh
# Borg cron backup script with desktop notifications
# Meant to be run as root
#
# Copyright (C) 2016 Olivier Bilodeau
# Licensed under the MIT License

# configuration
USER=
REPOSITORY=
COMPRESSION=zlib,5

# derived information
export BORG_CACHE_DIR=/home/$USER/.cache/borg/
USERID=`id -u $USER`

borg create -v --stats                          \
    --compression $COMPRESSION                  \
    $REPOSITORY::'{hostname}-{now:%Y-%m-%d}'    \
    /home/$USER/

if [[ $? == 0 ]]; then
        MSG="Backup success"
        ICON=document-send
else
        MSG="Backup failed... See root's dead.letter for details."
        ICON=dialog-warning
fi
sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USERID/bus notify-send 'BorgBackup' "$MSG" --icon=$ICON

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machine's archives also.
borg prune -v $REPOSITORY --prefix '{hostname}-' \
    --keep-daily=7 --keep-weekly=4 --keep-monthly=6
