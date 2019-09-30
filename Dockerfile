FROM ubuntu:latest
MAINTAINER Nicolas Decaux <decauxnico@gmail.com>
#MAINTAINER Lars Kellogg-Stedman <lars@oddbit.com>
# Forked from https://github.com/larsks/docker-image-logitech-media-server

ENV SQUEEZE_VOL /srv/squeezebox
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV TZ Europe/Paris

COPY entrypoint.sh /entrypoint.sh
COPY start-squeezebox.sh /start-squeezebox.sh
COPY libnet-sdp-perl_0.07-1_all.deb /tmp/libnet-sdp-perl_0.07-1_all.deb

RUN chmod 755 /entrypoint.sh && \
	chmod 755 /start-squeezebox.sh && \
	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y --no-install-recommends install \
		curl \
		wget \
		faad \
		flac \
		lame \
		sox \
		tzdata \
		wavpack \
		libgomp1 \
		ca-certificates \
		libcrypt-ssleay-perl \
		openssl \
		libio-socket-ssl-perl \
		libcrypt-openssl-bignum-perl \
		libcrypt-openssl-random-perl \
		libcrypt-openssl-rsa-perl \
		libio-socket-inet6-perl \
		libwww-perl \
		avahi-utils \
		libio-socket-ssl-perl \
		mplayer \
		avahi-daemon && \
	dpkg -i /tmp/libnet-sdp-perl_0.07-1_all.deb && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf
ENV LMS_VERSION "7.9.2"
ENV PACKAGE_VERSION_URL=http://www.mysqueezebox.com/update/?version=${LMS_VERSION}&revision=1&geturl=1&os=deb

RUN url=$(curl "$PACKAGE_VERSION_URL" | sed 's/_all\.deb/_amd64\.deb/') && \
	curl -Lsf -o /tmp/logitechmediaserver.deb $url && \
	dpkg -i /tmp/logitechmediaserver.deb && \
	rm -f /tmp/logitechmediaserver.deb && \
	apt-get update && \
	apt-get -y --no-install-recommends install \
	        libdbi-perl \
		libev-perl \
		libxml-parser-perl \
		libhtml-parser-perl \
		libjson-xs-perl \
		libdigest-sha-perl \
		libyaml-libyaml-perl \
		libsub-name-perl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	for ASDF in 5.12 5.14 5.16 5.18 5.20 5.22; do rm -r /usr/share/squeezeboxserver/CPAN/arch/$ASDF; done

# This will be created by the entrypoint script.
RUN userdel squeezeboxserver

VOLUME $SQUEEZE_VOL
EXPOSE 3483/tcp 3483/udp 9000/tcp 9090/tcp 49152-49162

ENTRYPOINT ["/entrypoint.sh"]
