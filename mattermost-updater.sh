#!/bin/bash

# NOTE: runs as an unprivileged user, hopefully
#
# Written by:  Tony Pignatelli for Megawire Inc. 2023

set -e
export DEBIAN_FRONTEND=noninteractive

log() {
        local level="$1"
        shift

        printf ">>>>> %s [%s]: %s\n" "$(date)" "$level" "$@"

}
debug() {
        log "debug" "$@"
}
error() {
        log "error" "$@"
}

update_mattermost() {
        debug "update_mattermost[enter] $@"

        debug "Check Running Server Version:"
        running_mm=$(sudo -u mattermost /opt/mattermost/bin/mmctl --local system version | cut -c 16- | cut -d. -f1-3)
        debug $running_mm
        debug "Check Current Version:"
        current_mm=$(curl -s -L https://mattermost.com/download | grep "Latest Release:" | cut -c 43- | rev | cut -c 5- | rev)
        debug $current_mm
## REGEX CHECK TO MAKE SURE VERION EXTRACTED FROM WEBSITE IS VALID
        if [[ $current_mm =~ ^([1-9]|[1-9]\d)+\.([0-9]|[0-9]\d)+\.([0-9]|[0-9]\d)+$ ]]; then
## COMPARE RUNNING VERSION WITH EXTRACTED VERSION
                if [ "$current_mm" = "$running_mm" ]; then
                        debug "Server is already up to date, exiting"
                        exit 1
                else
## OPTIONAL CODE FOR CONFIRMATION PROMPT
        #               read -p "Do you want to proceed? (yes/no) " yn
        #
        #               case $yn in 
        #                       yes ) echo ok, we will proceed;;
        #                       no ) echo exiting...;
        #                               exit;;
        #                       * ) echo invalid response;
        #                               exit 1;;
        #               esac
                        debug "Download current version to /tmp:"
                        sudo wget -q -P /tmp https://releases.mattermost.com/$current_mm/mattermost-team-$current_mm-linux-amd64.tar.gz

                        debug "Extract:"
                        sudo tar -xf /tmp/mattermost-team-$current_mm-linux-amd64.tar.gz --transform='s,^[^/]\+,\0-upgrade,' -C /tmp

                        debug "Stopping Mattermost:"
                        sudo systemctl stop mattermost

                        debug "Delete old version"
                        sudo find /opt/mattermost/ /opt/mattermost/client/ -mindepth 1 -maxdepth 1 \! \( -type d \( -path /opt/mattermost/client -o -path /opt/mattermost/client/plugins -o -path /opt/mattermost/config -o -path /opt/mattermost/logs -o -path /opt/mattermost/plugins -o -path /opt/mattermost/data \) -prune \) | sort | sudo xargs rm -r

                        debug "Copy new version:"
                        sudo cp -an /tmp/mattermost-upgrade/. /opt/mattermost/

                        debug "Update Permissions:"
                        sudo chown -R mattermost:mattermost /opt/mattermost

                        debug "Allow bind to low ports:"
                        sudo setcap cap_net_bind_service=+ep /opt/mattermost/bin/mattermost

                        debug "Start Mattermost:"
                        sudo systemctl start mattermost

                        debug "Cleanup:"
                        sudo rm -rf /tmp/mattermost*
                        #sudo rm -if /tmp/mattermost*.gz

                fi
        else
                debug "Invalid Version, Exiting...."
        fi
}
main() {
        debug "main[enter] $@"

        local profile="$1"

        update_mattermost

        debug "main[leave] $@"
}

main "$@"
