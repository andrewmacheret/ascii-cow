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
test_url() {
  echo -e "\nTesting url: $1"
  output="$( curl -s "$1" )"
  echo -e "$output"
  [[ "$output" != "" ]] || error "Test failed - no output"
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

docker run -d --name ascii-cow-test andrewmacheret/ascii-cow
sleep 1

test_url "http://localhost:8080/ascii-cows?url=$url&width=180"

docker rm -f ascii-cow-test

version=1.1

echo -e '\nTagging ...'
docker tag andrewmacheret/ascii-cow:latest andrewmacheret/ascii-cow:"$version"

echo -e '\nPushing ...'
#docker login
docker push andrewmacheret/ascii-cow:latest
docker push andrewmacheret/ascii-cow:"$version"

cleanup

