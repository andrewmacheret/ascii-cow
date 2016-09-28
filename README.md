# ascii-cow

[![Build Status](https://travis-ci.org/andrewmacheret/ascii-cow.svg?branch=master)](https://travis-ci.org/andrewmacheret/ascii-cow) [![Docker Stars](https://img.shields.io/docker/stars/andrewmacheret/ascii-cow.svg)](https://hub.docker.com/r/andrewmacheret/ascii-cow/) [![Docker Pulls](https://img.shields.io/docker/pulls/andrewmacheret/ascii-cow.svg)](https://hub.docker.com/r/andrewmacheret/ascii-cow/) [![License](https://img.shields.io/badge/license-MIT-lightgray.svg)](LICENSE.md)

Give it an image and a size, and get colorful ascii art spoken by a cow.

## Running locally:

Dependencies:

  * [im2a](https://github.com/tzvetkoff/im2a)
  * [perl](https://www.perl.org/)
  * [cowsay](https://en.wikipedia.org/wiki/Cowsay)
  * [bash](https://www.gnu.org/software/bash/)

Run it:

  ```bash
  ./ascii-cow.sh -f example.jpg -w 80
  
  url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'
  ./ascii-cow.sh -u "$url" -w 80
  ```

## Running docker container:

Dependencies:

  * [docker](https://www.docker.com/products/overview)

Run it:

  ```bash
  # convert a file
  docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -f example.jpg -w 80
  
  # convert a url
  url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'
  docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -u "$url" -w 80

  # run as a server on port 8080
  docker run -d andrewmacheret/ascii-cow

  # convert a url via a GET request
  url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'
  echo -e "$( curl -s "http://localhost:8080/ascii-cows?url=$url&width=80" )"
  ```

## Building docker container from source:

Dependencies:

  * [docker](https://www.docker.com/products/overview)
  * [git](https://git-scm.com/downloads)
  * [tar](https://en.wikipedia.org/wiki/Tar_(computing))
  * [bash](https://www.gnu.org/software/bash/)

Build it:

  ```bash
  ./build.sh
  ```

## Example result:

![Screenshot](screenshot.png?raw=true "Screenshot")

