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

./build.sh

file='example.jpg'
url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'

test ./ascii-cow.sh -f "$file" -w 40
test ./ascii-cow.sh -f "$file" -w 40 -h 20
test ./ascii-cow.sh -u "$url" -w 40 -h 20
test docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -f "$file" -w 40
test docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -f "$file" -w 40 -h 20
test docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -u "$url" -w 40 -h 20

version=1.1

echo -e '\nTagging ...'
docker tag andrewmacheret/ascii-cow:latest andrewmacheret/ascii-cow:"$version"

echo -e '\nPushing ...'
#docker login
docker push andrewmacheret/ascii-cow:latest
docker push andrewmacheret/ascii-cow:"$version"

cleanup

