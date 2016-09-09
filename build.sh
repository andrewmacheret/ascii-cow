#!/bin/bash -e

# build cowsay.tar.gz
[[ -d cowsay/ ]] || git clone https://github.com/schacon/cowsay.git
[[ -f im2a.tar.gz ]] || tar cvzf cowsay.tar.gz cowsay/

# build im2a.tar.gz
[[ -d im2a/ ]] || git clone https://github.com/tzvetkoff/im2a.git
[[ -f im2a.tar.gz ]] || tar cvzf im2a.tar.gz im2a/

docker build --build-arg http_proxy="$http_proxy" --build-arg https_proxy="$https_proxy" --build-arg no_proxy="$no_proxy" -t andrewmacheret/ascii-cow .

