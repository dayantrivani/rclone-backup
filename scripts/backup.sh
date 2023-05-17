#!/bin/bash

. /app/includes.sh

function sync() {
    local HAS_ERROR="FALSE"

    for RCLONE_SOURCE_X in "${RCLONE_SOURCE_LIST[@]}"
    do
    regex="\(([^)]+)\)" # match every letter inside brackets()
    if [[ $RCLONE_SOURCE_X =~ $regex ]]; then
        RCLONE_SOURCE_DESC_X=${BASH_REMATCH[1]} # capture the matched string
        RCLONE_SOURCE_NAME_X=${RCLONE_SOURCE_X/($inside_brackets)/}
    fi
        for RCLONE_REMOTE_X in "${RCLONE_REMOTE_LIST[@]}"
        do
            color blue "sync source $(color yellow "[${RCLONE_SOURCE_NAME_X}]") to remote $(color yellow "[${RCLONE_REMOTE_X}/${RCLONE_SOURCE_DESC_X}/]")"

            rclone ${RCLONE_GLOBAL_FLAG} sync "${RCLONE_SOURCE_NAME_X}" "${RCLONE_REMOTE_X}/${RCLONE_SOURCE_DESC_X}/"
            if [[ $? != 0 ]]; then
                color red "sync failed"

                HAS_ERROR="TRUE"
            fi
        done
    done 

    if [[ "${HAS_ERROR}" == "TRUE" ]]; then
        send_mail_content "FALSE" "File sync failed at $(date +"%Y-%m-%d %H:%M:%S %Z")."

        exit 1
    fi
}


color blue "running the sync program at $(date +"%Y-%m-%d %H:%M:%S %Z")"

# Check if this script is already running
if [ `lsof | grep $0 | wc -l | tr -d ' '` -gt 1 ]
then
    color red "WARNING: A previous sync is still running. Skipping new backup."
    exit 1
fi

init_env
sync

send_mail_content "TRUE" "The file was successfully synced at $(date +"%Y-%m-%d %H:%M:%S %Z")."
send_ping

color none ""
