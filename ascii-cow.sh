#!/bin/bash

usage() {
  [[ "$1" != "" ]] && echo "ERROR: $1" 1>&2
  cat 1>&2 <<EOF
USAGE: $( basename "$0" ) <SOURCE> <SIZE> [OTHER]

Option                               | Group  | Default
-------------------------------------+--------+--------
{-f|--file}          <IMAGE-FILE>    | SOURCE |
{-u|--url}           <IMAGE-URL>     | SOURCE |
{-w|--width}         <WIDTH>         | SIZE   |
{-h|--height}        <HEIGHT>        | SIZE   |
{-a|--aspect-ratio}  <WIDTH:HEIGHT>  | SIZE   | 4:3
{-s|--cowsay}                        | OTHER  | yes
{-t|--cowthink}                      | OTHER  |
{-c|--cow-args}      <COW_ARGS>      | OTHER  |
{-i|--im2a}          <IM2A_ARGS>     | OTHER  |

Additional notes:

 * SOURCE must be either file or url.

 * SIZE must include at least width or height. Aspect ratio will be ignored
if both width and height are specified.

 * Only one of --cowsay or --cowthink should be specified.
EOF
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

# defaults
IMAGE_OPTION=
IMAGE_FILE=
WIDTH=
HEIGHT=
ASPECT_RATIO='4:3'
COW_CMD='cowsay'
COW_ARGS=
IM2A_ARGS=

while [[ $# > 0 ]] ; do
  arg="$1"
  shift

  case "$arg" in
    -f|--file)
      IMAGE_OPTION='-f'
      IMAGE_FILE="$1"
      shift
      ;;
    -u|--url)
      IMAGE_OPTION='-u'
      IMAGE_FILE="$1"
      shift
      ;;
    -w|--width)
      WIDTH="$1"
      shift
      ;;
    -h|--height)
      HEIGHT="$1"
      shift
      ;;
    -a|--aspect-ratio)
      ASPECT_RATIO="$1"
      shift
      ;;
    -s|--cow-say)
      COW_CMD='cowsay'
      ;;
    -t|--cow-think)
      COW_CMD='cowthink'
      ;;
    -c|--cow-args)
      COW_ARGS=$1
      shift
      ;;
    -i|--im2a-args)
      IM2A_ARGS=$1
      shift
      ;;
    *)
      usage "Unknown option: $arg"
      ;;
  esac
done

# check arguments
[[ "${IMAGE_OPTION}" == "-f" ]] || [[ "${IMAGE_OPTION}" == "-u" ]] || usage "Must specify image or file"

# ensure correct format for width, height, and aspect ratio
[[ "${WIDTH}"  == "" ]] || [[ "${WIDTH}"  =~ ^[0-9]+$ ]] || usage "Width must be a number"
[[ "${HEIGHT}" == "" ]] || [[ "${HEIGHT}" =~ ^[0-9]+$ ]] || usage "Height must be a number"
[[ "${ASPECT_RATIO}" == "" ]] || [[ "${ASPECT_RATIO}" =~ ^[0-9]+:[0-9]+$ ]] || usage "Aspect ratio must be in the format NUMBER:NUMBER"

# ensure at least one of width or height are specified
[[ "${WIDTH}" != "" ]] || [[ "${HEIGHT}" != "" ]] || usage "Width or height must be specified"

# check dependencies
which im2a >/dev/null || {
  error "Dependency im2a missing. Visit https://github.com/tzvetkoff/im2a"
}
which identify >/dev/null || {
  error "Dependency imagemagick missing."
}
which perl >/dev/null || {
  error "Dependency perl missing."
}
which cowsay >/dev/null || {
  error "Dependency cowsay missing."
}

load_file() {
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
}

load_image_size() {
  image_size="$( identify "$FILE" | cut -d' ' -f3 )"
  image_width="$( cut -dx -f1 <<< "$image_size" )"
  image_height="$( cut -dx -f2 <<< "$image_size" )"
  [[ $image_width  != "" ]] && [[ $image_width  -gt 0 ]] || error "Could not determine image width"
  [[ $image_height != "" ]] && [[ $image_height -gt 0 ]] || error "Could not determine image height"
  ASPECT_WIDTH="$( cut -d':' -f1 <<< "$ASPECT_RATIO" )"
  ASPECT_HEIGHT="$( cut -d':' -f2 <<< "$ASPECT_RATIO" )"
}

calculate_size() {
  if [[ "${WIDTH}" != "" ]] && [[ "${HEIGHT}" == "" ]]; then
    load_image_size
    HEIGHT=$(( ($WIDTH * $image_width * $ASPECT_HEIGHT) / ($image_height * $ASPECT_WIDTH) ))
    #echo "$HEIGHT = ($WIDTH * $image_width * $ASPECT_HEIGHT) / ($image_height * $ASPECT_WIDTH)"
  elif [[ "${WIDTH}" == "" ]] && [[ "${HEIGHT}" != "" ]]; then
    load_image_size
    WIDTH=$(( ($HEIGHT * $image_height * $ASPECT_WIDTH) / ($image_width * $ASPECT_HEIGHT) ))
    #echo "$WIDTH = ($HEIGHT * $image_height * $ASPECT_WIDTH) / ($image_width * $ASPECT_HEIGHT)"
  fi
}

convert_image() {
  im2a $IM2A_ARGS -W "${WIDTH}" -H "${HEIGHT}" "${FILE}" |
    cowsay $COW_ARGS -n |
    perl -p -e 's/(([-_]){'"${WIDTH}"'})[-_]+/\1\2\2/' |
    perl -p -e 's/ +([|\/\\]) *$/ \1/'
}

load_file

calculate_size

convert_image

cleanup

