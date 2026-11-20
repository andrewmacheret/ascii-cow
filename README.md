# ascii-cow

[![CI](https://github.com/andrewmacheret/ascii-cow/actions/workflows/ci.yml/badge.svg)](https://github.com/andrewmacheret/ascii-cow/actions/workflows/ci.yml) [![License](https://img.shields.io/badge/license-MIT-lightgray.svg)](https://github.com/andrewmacheret/ascii-cow/blob/master/LICENSE.md)

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
  docker run --rm -it ghcr.io/andrewmacheret/ascii-cow ./ascii-cow.sh -f example.jpg -w 80
  
  # convert a url
  url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'
  docker run --rm -it ghcr.io/andrewmacheret/ascii-cow ./ascii-cow.sh -u "$url" -w 80

  # run as a server on port 8080
  docker run -d -p 8080:80 ghcr.io/andrewmacheret/ascii-cow

  # convert a url via a GET request
  url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'
  echo -e "$( curl -s "http://localhost:8080/convert?url=$url&width=80" )"
  ```

## Server API:

  * `GET /` lists the API URLs.
  * `GET /cows` lists the cow files.
  * `GET /convert` converts an image from a URL. Query parameters:
    * `url` (required): an http or https image URL. Local files can only be converted with `ascii-cow.sh -f`.
    * `width` and/or `height` (at least one): positive integers.
    * `aspect-ratio`: like `4:3`. Ignored if both width and height are given.
    * `say` or `think`: use cowsay (default) or cowthink.
    * `eyes`, `tongue`: 1 or 2 characters.
    * `feeling`: one of `borg`, `dead`, `greedy`, `paranoia`, `stoned`, `tired`, `wired`, `youthful`.
    * `cow-file`: a cow name from `/cows`.

The server listens on port 80, or on `$PORT` if set. Bad input returns 400, and a failed conversion returns 500.

## Building docker container from source:

Dependencies:

  * [docker](https://www.docker.com/products/overview)

Build it:

  ```bash
  docker build -t ascii-cow .
  ```

## Example result:

![Screenshot](screenshot.png?raw=true "Screenshot")

