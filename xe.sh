#!/usr/bin/env bash
#
# Currency convert using xe
#
#/ Usage:
#/   ./xe.sh <from_currency> <to_current> <ammount>

set -e
set -u

usage() {
    printf "\n%b\n" "$(grep '^#/' "$0" | cut -c4-)" && exit 0
}

set_args() {
    _HOME_DIR=$(dirname "${BASH_SOURCE[0]}")
    _FROM_CURRENCY="${1:-}"
    _TO_CURRENCY="${2:-}"
    _AMOUNT="${3:-}"
    _URL="https://www.xe.com/api/page_resources/converter.php?fromCurrency=${_FROM_CURRENCY^^}&toCurrency=${_TO_CURRENCY^^}"
}

set_command() {
    local platform
    platform="$(uname -s)"

    if [[ "$platform" == *"inux"* ]]; then
        _DECODER="$_HOME_DIR/decoder-lin"
    elif [[ "$platform" == *"arwin"* ]]; then
        _DECODER="$_HOME_DIR/decoder-mac"
    else
        echo "OS not support!" && exit 1
    fi

    _CURL="$(command -v curl)" || command_not_found "curl"
}

command_not_found() {
    printf "%b\n" '\033[31m'"$1"'\033[0m command not found!' && exit 1
}

check_var() {
    if [[ -z "$_AMOUNT" ]]; then
        echo 'Missing input arguments!' && usage
    fi
}

get_rate() {
    local encodedRate

    encodedRate=$($_CURL -sSX GET "$_URL" \
        -H 'Accept: */*' \
        -H 'Accept-Language: en-US,en;q=0.5' \
        -H 'Cache-Control: no-cache' \
        -H 'Connection: keep-alive' \
        -H 'DNT: 1' \
    | sed -E 's/.*rate"\:"//;s/".*//')

    $_DECODER "$encodedRate"
}

calculate_rate() {
    printf "%.2f\n" "$(echo "$1*$2" | bc)"
}

main() {
    set_args "$@"
    check_var
    set_command
    calculate_rate "$_AMOUNT" "$(get_rate)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
