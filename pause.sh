#!/bin/bash

#Effectively "pause" motion alerts from camera by blocking smtp traffic from the camera
# Parameters:    $1  - how many minutes to wait ($drip)
#                $2  - last octet of camera ip address
# Usage:  ./pause.sh 15 34
bro="$2"
drip="$1"
log() {
        shift
        printf ">>>>> %s [%s]: %s\n" "$(date)" "$bro" "$@"
}
debug() {
        log "debug" "$@"
}
error() {
        log "error" "$@"
}


block_bro_from_trippin() {
        #Add firewall to block port 25 sourcing from our camera specified with parameter 2
        debug "Blocking TCP 25 traffic"
        sudo iptables -A INPUT -s 10.0.0.$bro -p tcp --dport 25 -j DROP

        #Wait for the requested amount of time specified by parameter 1 (minutes)
        drip=$((60*$drip))
        sleep $drip

        debug "Unblocking TCP 25 traffic"
        #Remove firewall rules from INPUT chain
        sudo iptables -F INPUT
}

main() {

        block_bro_from_trippin
}

main "$@"
~              
