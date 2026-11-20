FROM debian:bookworm-slim AS im2a

ARG IM2A_REF=8a2111b4b8b094c136efb824343644e8721427eb

RUN apt-get update &&\
  apt-get install -y --no-install-recommends ca-certificates git build-essential autoconf automake libtool pkg-config libmagick++-dev libncurses-dev &&\
  git clone https://github.com/tzvetkoff/im2a.git /tmp/im2a &&\
  cd /tmp/im2a &&\
  git checkout "${IM2A_REF}" &&\
  ./bootstrap &&\
  ln -s "$(ls /usr/bin/Magick++-config.*)" /usr/bin/Magick++-config &&\
  ./configure &&\
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
