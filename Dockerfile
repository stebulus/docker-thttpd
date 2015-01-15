# A thttpd daemon.
# Start the server via:
#   docker run --rm -itP -v DIR_TO_SERVE_FROM:/var/www:ro thttpd
# Then get the port number from `docker ps` and visit http://localhost:PORT

FROM ubuntu:14.04
MAINTAINER Steven Taschuk <steven@amotlpaa.org>

COPY thttpd-2.26.tar.gz.sha256 /usr/local/src/
COPY thttpd-2.26-recognize_x86_64.patch /usr/local/src/

WORKDIR /usr/local/src
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
    && wget http://acme.com/software/thttpd/thttpd-2.26.tar.gz \
    && shasum -a 256 -c thttpd-2.26.tar.gz.sha256 \
    && apt-get purge -y --auto-remove wget

WORKDIR /tmp 
RUN apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev \
        make \
        patch \
    && tar zxf /usr/local/src/thttpd-2.26.tar.gz \
    && cd thttpd-2.26 \
    && patch -p1 </usr/local/src/thttpd-2.26-recognize_x86_64.patch \
    && ./configure \
    && make SUBDIRS= \
    && make SUBDIRS= install \
    && mkdir /var/www \
    && apt-get purge --auto-remove -y \
        gcc \
        libc6-dev \
        make \
        patch

EXPOSE 80
CMD ["/usr/local/sbin/thttpd", "-l", "-", "-d", "/var/www", "-D"]
