from gliderlabs/alpine:3.3

# install cowsay
ADD cowsay.tar.gz /tmp
RUN apk-install --no-cache perl &&\
  cd /tmp/cowsay/ &&\
  echo | ./install.sh &&\
  rm -rf /tmp/cowsay

# install im2a
ADD im2a.tar.gz /tmp
RUN apk-install --no-cache imagemagick-dev &&\
  apk --update add --virtual build-dependencies make autoconf automake libtool gawk gcc g++ ncurses-dev &&\
  cd /tmp/im2a/ &&\
  ./bootstrap &&\
  ./configure &&\
  mkdir lib-tmp/ &&\
  ln -s /usr/lib/liblcms2.so.2 /usr/lib/liblcms2.so &&\
  ln -s /usr/lib/libfontconfig.so.1 /usr/lib/libfontconfig.so &&\
  ln -s /usr/lib/libfreetype.so.6 /usr/lib/libfreetype.so &&\
  ln -s /lib/libz.so.1 /lib/libz.so &&\
  make install &&\
  rm -rf /tmp/im2a &&\
  apk del build-dependencies

RUN apk-install --no-cache bash curl

WORKDIR /root
ADD ascii-cow.sh .
ADD example.jpg .

CMD ["bash"]

