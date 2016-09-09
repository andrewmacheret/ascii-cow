# ascii-cow

Give it an image and a size, and get colorful ascii art spoken by a cow.

## Running locally:

Dependencies:

  * [im2a](https://github.com/tzvetkoff/im2a)
  * [cowsay](https://en.wikipedia.org/wiki/Cowsay)
  * [coreutils](https://www.gnu.org/software/coreutils/coreutils.html) - for gsed

Run it:

  ```bash
  ./ascii-cow.sh -f example.jpg 80 40
  
  url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'
  ./ascii-cow.sh -u "$url" 80 40
  ```

## Running docker container:

Dependencies:

  * [docker](https://www.docker.com/products/overview)

Run it:

  ```bash
  docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -f example.jpg 80 40
  
  url='https://raw.githubusercontent.com/andrewmacheret/ascii-cow/master/example.jpg'
  docker run --rm -it andrewmacheret/ascii-cow ./ascii-cow.sh -u "$url" 80 40
  ```

## Building docker container from source:

Dependencies:

  * [docker](https://www.docker.com/products/overview)
  * [git](https://git-scm.com/downloads)
  * [tar](https://en.wikipedia.org/wiki/Tar_(computing))

Build it:

  ```bash
  ./build.sh
  ```

## Exmaple result:

![Screenshot](screenshot.png?raw=true "Screenshot")

