#! /bin/bash

# Uncomment below to show output of script
#set -xe

# print INFO message to stdout
# Argument: 
#    $1: INFO message to print
log_info() {
    local MSG="$1"
    printf "%s - [SCRIPT INFO] %s\n" "$(date)" "$MSG"
}

# print ERROR message to stderr
# Argument: 
#    $1: ERROR message to print
log_error() {
    local MSG="$1"
    printf "%s - [SCRIPT ERROR] %s\n" "$(date)" "$MSG" >&2
}
