#!/bin/bash -e

usage() {
  echo "$( basename "$0" ) <IMAGE-FILE> <WIDTH> <HEIGHT>" 1>&2
  exit 1
}

[[ "$#" -eq 3 ]] || usage

IMAGE_FILE="$1"
WIDTH="$2"
HEIGHT="$3"

which im2a >/dev/null || {
  echo "im2a required. Run `brew install tzvetkoff/extras/im2a` on OS/X or visit https://github.com/tzvetkoff/im2a for alternatives." 1>&2
  exit 1
}

which cowsay >/dev/null || {
  echo "cowsay required. Run `brew install cowsay` on OS/X or check your package manager." 1>&2
  exit 1
}

which gsed >/dev/null || {
  echo "gsed required. Run `brew install coreutils` on OS/X or check your package manager." 1>&2
  exit 1
}

im2a -W "$WIDTH" -H "$HEIGHT" "$IMAGE_FILE" | cowsay -e .o -n | gsed -r 's/(([-_]){'"$WIDTH"'})[-_]+/\1\2\2/' | gsed -r 's/ +([|\/\]) *$/ \1/'
