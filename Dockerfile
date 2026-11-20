# syntax=docker/dockerfile:1
FROM debian:bookworm-slim AS im2a

ARG IM2A_REF=8a2111b4b8b094c136efb824343644e8721427eb

# im2a wants Magick++-config, which debian doesn't ship under that name
COPY --chmod=755 <<'SCRIPT' /usr/local/bin/Magick++-config
#!/bin/sh
case "$1" in
  --version) pkg-config --modversion Magick++ ;;
  --cppflags|--cxxflags) pkg-config --cflags Magick++ ;;
  --ldflags) pkg-config --libs-only-L Magick++ ;;
  --libs) pkg-config --libs Magick++ ;;
esac
SCRIPT

RUN apt-get update &&\
  apt-get install -y --no-install-recommends ca-certificates git build-essential autoconf automake libtool pkg-config libmagick++-dev libncurses-dev &&\
  git clone https://github.com/tzvetkoff/im2a.git /tmp/im2a &&\
  cd /tmp/im2a &&\
  git checkout "${IM2A_REF}" &&\
  ./bootstrap &&\
  pkg-config --list-all | grep -i magick &&\
  ./configure --with-magick++-config=/usr/local/bin/Magick++-config &&\
  make &&\
  make install

FROM node:22-bookworm-slim

RUN apt-get update &&\
  apt-get install -y --no-install-recommends bash curl ca-certificates cowsay imagemagick libmagick++-6.q16-8 perl &&\
  rm -rf /var/lib/apt/lists/*

# debian puts cowsay in /usr/games
ENV PATH="/usr/games:${PATH}"

COPY --from=im2a /usr/local/bin/im2a /usr/local/bin/im2a

WORKDIR /root
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY ascii-cow.sh ascii-cow-server.js example.jpg ./

EXPOSE 80

CMD ["node", "ascii-cow-server.js"]
