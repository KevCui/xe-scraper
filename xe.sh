#!/usr/bin/env bash
#
# Currency convertion using xe
#
#/ Usage:
#/   ./xe.sh <from_currency> <to_current> <ammount>

set -e
set -u

usage() {
    printf "\n%b\n" "$(grep '^#/' "$0" | cut -c4-)" && exit 0
}

set_args() {
    _FROM_CURRENCY="${1:-}"
    _TO_CURRENCY="${2:-}"
    _AMOUNT="${3:-}"
    _HOST="https://www.xe.com"
    _URL="$_HOST/api/page_resources/converter.php?fromCurrency=${_FROM_CURRENCY^^}&toCurrency=${_TO_CURRENCY^^}"
}

set_command() {
    _CURL="$(command -v curl)" || command_not_found "curl"
    _NODE="$(command -v node)" || command_not_found "node"
    _DECODER="$(dirname "$0")/decoder.js"
    if [[ ! -s "$_DECODER" ]]; then
        fetch_decoder
    fi
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

    $_NODE "$_DECODER" "$encodedRate"
}

calculate_rate() {
    printf "%.2f\n" "$(echo "$1*$2" | bc)"
}

fetch_decoder() {
    local j
    j=$($_CURL -sS "$_HOST" \
        | grep 'xe/js/react/commons.' \
        | sed -E 's:.*/themes/xe/js/react/commons\.:/themes/xe/js/react/commons.:' \
        | awk -F '"' '{print $1}')
    $_CURL -sS "$_HOST/$j" \
        | sed -E 's/.*e\.decodeRatesData=function/function decodeRatesData/' \
        | sed -E 's/,e\.getUnitRate.*//' \
        | head -1 \
        | sed -E 's/,e\.decode64=function/function decode64/' \
        | sed -E 's/this\.decode64/decode64/' > "$_DECODER"
    echo "console.log(decodeRatesData(process.argv[2]))" >> "$_DECODER"
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
