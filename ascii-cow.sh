#!/bin/bash -e

usage() {
  echo "$( basename "$0" ) {-f IMAGE-FILE | -u IMAGE-URL} {WIDTH} {HEIGHT}" 1>&2
  exit 1
}

[[ "$#" -eq 4 ]] || usage

IMAGE_OPTION="$1"
IMAGE_FILE="$2"
WIDTH="$3"
HEIGHT="$4"

[[ "$IMAGE_FILE" != "" ]] || usage
[[ "$WIDTH" != "" ]] && [[ "$WIDTH" -gt 0 ]] || usage
[[ "$HEIGHT" != "" ]] && [[ "$HEIGHT" -gt 0 ]] || usage
[[ "$IMAGE_OPTION" == "-f" ]] || [[ "$IMAGE_OPTION" == "-u" ]] || usage

which im2a >/dev/null || {
  echo "im2a required. Run 'brew install tzvetkoff/extras/im2a' on OS/X or visit https://github.com/tzvetkoff/im2a for alternatives." 1>&2
  exit 1
}

which cowsay >/dev/null || {
  echo "cowsay required. Run 'brew install cowsay' on OS/X or check your local package manager." 1>&2
  exit 1
}

SED="$(which gsed || which sed)"
(echo | "$SED" -r 's/.//' 2>&1 >/dev/null) || {
  echo "gsed required. Run 'brew install coreutils' on OS/X or check your local package manager." 1>&2
  exit 1
}

[[ "$IMAGE_OPTION" == "-f" ]] || (which curl >/dev/null) || {
  echo "curl is required for the -u option. Please check your local package manager." 1>&2
  exit 1
}

eyes=.0

if [[ "$IMAGE_OPTION" == "-f" ]]; then
  im2a -W "$WIDTH" -H "$HEIGHT" "$IMAGE_FILE" | cowsay -e "$eyes" -n | "$SED" -r 's/(([-_]){'"$WIDTH"'})[-_]+/\1\2\2/' | "$SED" -r 's/ +([|\/\]) *$/ \1/'
else
  curl -fsSL "$IMAGE_FILE" | im2a -W "$WIDTH" -H "$HEIGHT" - | cowsay -e "$eyes" -n | "$SED" -r 's/(([-_]){'"$WIDTH"'})[-_]+/\1\2\2/' | "$SED" -r 's/ +([|\/\]) *$/ \1/'
fi
