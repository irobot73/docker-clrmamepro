#! /bin/bash

app="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$app/logging.sh"

set -e
# Uncomment below to show output of script
#set -x

# Obtain latest MAME package
get_mame() {
    if [ -z "$1" ]; then
        log_error "Function 'get_clrmamepro' parameter cannot be NULL."; exit 3;
    fi

    local dst_dir=$(dirname "$1")

    if [ ! -d "$dst_dir" ]; then
        log_error "Destination folder '$dst_dir' does not exist."; exit 7;
    fi

    local MAME_LATEST_BINARY=$( \
        curl https://www.mamedev.org/release.html/ | \
        sed -n 's/.*href="\([^"]*\).*/\1/p' | \
        grep -i github | \
        grep -i _64bit.exe )

    curl -L -f -C - -o "$1" "$MAME_LATEST_BINARY"

    chmod 555 "$1"
}

# Extract .EXE files from the latest MAME download {<full file path of EXE> <destination dir>}
extract_mame() {
    local file_list=/opt/scripts/mame_files_to_extract.txt

    if [ -z "$1" ]; then
        log_error "Function 'extract_mame' parameter 1 cannot be NULL."; exit 3;
    elif [ ! -f "$1" ]; then
        log_error "File '$1' not found."; exit 5
    elif [ -z "$2" ]; then
        log_error "Function 'extract_mame' parameter 2 cannot be NULL."; exit 3;
    elif [ ! -d "$2" ]; then
        log_error "Destination folder '$2' does not exist."; exit 7
    fi

    if [ ! -f "$file_list" ]; then
        log_info "File list '$file_list' not found.  Extracting all MAME executables."
        7z e -y -o"$2" "$1" *.exe
    else
        log_info 'Extracting MAME files using file list.'
        7z e -y -o"$2" "$1" @$file_list
    fi    
}

# Obtain latest ClrMAMEPro ZIP file
get_clrmamepro() {
    if [ -z "$1" ]; then
        log_error "Function 'get_clrmamepro' parameter cannot be NULL."; exit 3;
    fi

    local dst_dir=$(dirname "$1")

    if [ ! -d "$dst_dir" ]; then
        log_error "Destination folder '$dst_dir' does not exist."; exit 7;
    fi

    local CMP_LATEST_BINARY=$( \
        curl https://mamedev.emulab.it/clrmamepro/ | \
        sed -n 's/.*href="\([^"]*\).*/\1/p' | \
        grep -i binaries | \
        grep -i _64.zip )

    curl -L -f -C - -o "$1" "https://mamedev.emulab.it/clrmamepro/$CMP_LATEST_BINARY"

    chmod 777 "$1"
}

# Setup/Verify ClrMAMEPro's' .INI file
setup_ini_file() {
    if [ -z "$1" ]; then
        log_error "Function 'setup_ini_file' parameter cannot be NULL."; exit 3;
    fi

    local src_dir=$(dirname "$1")

    if [ ! -d "$src_dir" ]; then
        log_error "Source folder '$src_dir' does not exist."; exit 7;
    fi

    if [ ! -f "$1" ]; then
        touch "$1"
        printf "[CMPRO SETTINGS]\nAdv_HideWindow = off" > "$1"
        log_info "Created file '$1'."
    else
        log_info "File '$1' already exists."
    fi

    chmod 666 "$1"
}

# Obtain latest ClrMAMEPro ZIP file {<full file path of ZIP> <destination dir>}
unzip_clrmamepro() {    
    if [ -z "$1" ]; then
        log_error "Function 'unzip_clrmamepro' parameter 1 cannot be NULL."; exit 3;
    elif [ ! -f "$1" ]; then
        log_error "File '$1' not found."; exit 5
    elif [ -z "$2" ]; then
        log_error "Function 'unzip_clrmamepro' parameter 2 cannot be NULL."; exit 3;
    elif [ ! -d "$2" ]; then
        log_error "Destination folder '$2' does not exist."; exit 7
    fi

    # Replace any missing a/o old file(s)
    #   https://www.manpagez.com/man/1/unzip/
    unzip -u "$1" -d "$2"
}

# Verify calls to script
#   '"") ;;' - If the $1 argument is empty, it’s a normal execution of the script instead of an external function call. Therefore, we continue the execution beyond the case statement
#   If a function name matches, we call the matched function with all arguments and exit the execution after the function execution
#   '*) log_error' - If we cannot find a matched function name, we think the caller attempted to call an invalid function. Therefore, we print the error log and exit
case "$1" in
    "") ;;
    extract_mame) "$@"; exit;;
    get_clrmamepro) "$@"; exit;;
    get_mame) "$@"; exit;;
    setup_ini_file) "$@"; exit;;
    unzip_clrmamepro) "$@"; exit;;
    *) log_error "Unkown function: $1()"; exit 2;;
esac
