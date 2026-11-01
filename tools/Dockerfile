FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

# Ubuntu 16.04 still has xenial on archive.ubuntu.com, but keep the
# Valid-Until check off in case the archive metadata gets re-signed.
RUN printf '%s\n' \
    'deb http://archive.ubuntu.com/ubuntu xenial main restricted universe multiverse' \
    'deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse' \
    'deb http://security.ubuntu.com/ubuntu xenial-security main restricted universe multiverse' \
    > /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y --no-install-recommends \
        openjdk-8-jdk \
        python2.7 \
        python3 \
        git curl wget ca-certificates openssh-client \
        zip unzip rsync bc bison flex gperf m4 \
        build-essential g++-multilib gcc-multilib \
        libc6-dev-i386 lib32z1-dev lib32ncurses5-dev lib32readline6-dev \
        lib32stdc++6 lib32z1 lib32ncurses5 \
        libssl-dev libelf-dev libncurses5-dev \
        libxml2-utils xsltproc pngcrush schedtool \
        ccache imagemagick gettext \
        liblz4-tool lzop device-tree-compiler \
        xz-utils squashfs-tools \
    && rm -rf /var/lib/apt/lists/*

# AOSP 8.1 build scripts invoke `python` and expect Python 2.
RUN ln -sf /usr/bin/python2.7 /usr/bin/python

# Jack 4.32 still negotiates TLSv1; OpenJDK 8u292 disables it by default.
# This only relaxes TLS inside the disposable build container (localhost).
RUN sed -i '/^jdk.tls.disabledAlgorithms=/ s/TLSv1, TLSv1.1, //' \
    /etc/java-8-openjdk/security/java.security

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PATH}
ENV LC_ALL=C
ENV LANG=C
ENV USE_CCACHE=1
ENV CCACHE_DIR=/ccache
ENV CCACHE_EXEC=/usr/bin/ccache

RUN useradd -m -u 1000 -U builder
USER builder
WORKDIR /src
