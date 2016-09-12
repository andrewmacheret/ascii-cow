#!/bin/bash

error() {
  echo "ERROR: $1"
  cleanup 1
}
cleanup() {
  [[ $1 != "" ]] && exit "$1" || exit 0
}
trap 'error "Unexpected error! Exit code: $?"' ERR
trap 'error "Interrupted!"' INT
trap 'error "Terminated!"' TERM

test() {
  echo -e "\nTesting: $@"
  "$@"
}

file='example.jpg'
url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'

test ./ascii-cow.sh -f "$file" 40 20
test ./ascii-cow.sh -u "$url" 40 20
test docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -f "$file" 40 20
test docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -u "$url" 40 20

echo -e '\nTagging ...'
docker tag andrewmacheret/ascii-cow:latest andrewmacheret/ascii-cow:1.0

echo -e '\nPushing ...'
docker push andrewmacheret/ascii-cow:latest
docker push andrewmacheret/ascii-cow:1.0

cleanup

