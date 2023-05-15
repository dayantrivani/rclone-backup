#!/bin/bash

. /app/includes.sh

function sync() {
    local HAS_ERROR="FALSE"

    for RCLONE_SOURCE_X in "${RCLONE_SOURCE_LIST[@]}"
    do
    IFS='|' read -r RCLONE_SOURCE_NAME_X RCLONE_SOURCE_DESC_X <<< "$RCLONE_SOURCE_X"
        for RCLONE_REMOTE_X in "${RCLONE_REMOTE_LIST[@]}"
        do
            color blue "sync source $(color yellow "[${RCLONE_SOURCE_NAME_X}]") to remote $(color yellow "[${RCLONE_REMOTE_X}${RCLONE_SOURCE_DESC_X}/]")"

            rclone ${RCLONE_GLOBAL_FLAG} sync "${RCLONE_SOURCE_NAME_X}" "${RCLONE_REMOTE_X}${RCLONE_SOURCE_DESC_X}/"
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

init_env
sync

send_mail_content "TRUE" "The file was successfully synced at $(date +"%Y-%m-%d %H:%M:%S %Z")."
send_ping

color none ""
