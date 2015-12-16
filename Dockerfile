FROM ubuntu:wily
MAINTAINER Pavel Pavlov
ENV DEBIAN_FRONTEND noninteractive
ENV HTS_COMMIT master

# Install repos and packages
RUN apt-get update && apt-get -y upgrade

# Install software and repos
RUN apt-get install -m -y wget git curl make dkms dpkg-dev python \
    build-essential pkg-config libssl-dev bzip2 \
    libavahi-client-dev zlib1g-dev libavcodec-dev libavutil-dev libavformat-dev libswscale-dev \
    libcurl4-gnutls-dev liburiparser-dev linux-firmware \
    debhelper

# checkout, build, and install tvheadend
RUN git clone https://github.com/tvheadend/tvheadend.git /opt/tvheadend \
  && cd /opt/tvheadend && git checkout ${HTS_COMMIT} && AUTOBUILD_CONFIGURE_EXTRA=--disable-libav_static ./Autobuild.sh

# Clean up APT and temporary files
RUN rm -r /opt/tvheadend && apt-get purge -qq build-essential pkg-config git
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN cd /opt/ && dpkg -i tvheadend_*.deb

EXPOSE 9981 9982

VOLUME /config /recordings /data

CMD ["tvheadend","-C","-u","hts","-g","hts","-c","/config"]
