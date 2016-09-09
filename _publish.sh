#!/bin/bash -e

echo -e '\nTesting option -f ...'
docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -f example.jpg 40 20

echo -e '\nTesting option -u ...'
url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'
docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -u "$url" 40 20

echo -e '\nTagging ...'
docker tag andrewmacheret/ascii-cow:latest andrewmacheret/ascii-cow:1.0

echo -e '\nPushing ...'
docker push andrewmacheret/ascii-cow:latest
docker push andrewmacheret/ascii-cow:1.0
