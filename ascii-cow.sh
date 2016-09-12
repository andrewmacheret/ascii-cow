#!/bin/bash

usage() {
  echo "USAGE: $( basename "$0" ) {-f IMAGE-FILE | -u IMAGE-URL} {WIDTH} {HEIGHT}" 1>&2
  cleanup 1
}
error() {
  echo "ERROR: $1" 1>&2
  cleanup 1
}
make_temp_dir() {
  TEMP_DIR="/tmp/${0##*/}-$$"
  mkdir -p "${TEMP_DIR}"
}
cleanup() {
  [[ "${TEMP_DIR}" != "" ]] && (rm -rf "${TEMP_DIR}" || echo "Failed to delete '${TEMP_DIR}'" 1>&2)
  [[ $1 != "" ]] && exit "$1" || exit 0
}
trap 'error "Unexpected error! Exit code: $?"' ERR
trap 'error "Interrupted!"' INT
trap 'error "Terminated!"' TERM

[[ "$#" -eq 4 ]] || usage

IMAGE_OPTION="$1"
IMAGE_FILE="$2"
WIDTH="$3"
HEIGHT="$4"
EYES=".0"

[[ "${IMAGE_FILE}" != "" ]] || usage
[[ "${WIDTH}" != "" ]] && [[ "${WIDTH}" -gt 0 ]] || usage
[[ "${HEIGHT}" != "" ]] && [[ "${HEIGHT}" -gt 0 ]] || usage
[[ "${IMAGE_OPTION}" == "-f" ]] || [[ "${IMAGE_OPTION}" == "-u" ]] || usage

which im2a >/dev/null || {
  error "Dependency im2a missing. Visit https://github.com/tzvetkoff/im2a"
}

which perl >/dev/null || {
  error "Dependency perl missing."
}

which cowsay >/dev/null || {
  error "Dependency cowsay missing."
}

if [[ "${IMAGE_OPTION}" == "-u" ]]; then
  (which curl >/dev/null) || {
    error "Dependency curl missing and is required for the -u option."
  }

  make_temp_dir
  FILE="${TEMP_DIR}/downloaded-image"
  curl -fsSL "${IMAGE_FILE}" > "${FILE}"
else
  FILE="${IMAGE_FILE}"
fi

im2a -W "${WIDTH}" -H "${HEIGHT}" "${FILE}" |
  cowsay -e "${EYES}" -n |
  perl -p -e 's/(([-_]){'"${WIDTH}"'})[-_]+/\1\2\2/' |
  perl -p -e 's/ +([|\/\\]) *$/ \1/'

cleanup

