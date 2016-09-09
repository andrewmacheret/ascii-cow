#!/bin/bash -e

# build cowsay.tar.gz
git clone https://github.com/schacon/cowsay.git
rm -rf cowsay/.git/ cowsay/.gitignore
tar cvzf cowsay.tar.gz cowsay/
rm -rf cowsay/

# build im2a.tar.gz
git clone https://github.com/tzvetkoff/im2a.git
rm -rf im2a/.git/ im2a/.gitignore
tar cvzf im2a.tar.gz im2a/
rm -rf im2a/

docker build --build-arg http_proxy="$http_proxy" --build-arg https_proxy="$https_proxy" --build-arg no_proxy="$no_proxy" -t andrewmacheret/ascii-cow .

