FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libogg-dev \
    libcurl4-openssl-dev \
    liblua5.3-dev \
    pkg-config \
    gengetopt \
    libtool \
    automake \
    nodejs \
    wget \
    nginx \
    supervisor \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libconfig-dev \
    libevent-dev \
    libwebsockets-dev \
    libavutil-dev \
    libavformat-dev \
    libavcodec-dev && \
    apt-get clean

    RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libglib2.0-dev \
    libconfig-dev \
    libnice-dev \
    libssl-dev \
    libsrtp2-dev \
    libsofia-sip-ua-dev \
    libopus-dev \
    libogg-dev \
    libcurl4-openssl-dev \
    libjansson-dev \
    liblua5.3-dev \
    libwebsockets-dev \
    zlib1g-dev \
    libmicrohttpd-dev \
    gengetopt \
    libtool \
    automake \
    cmake \
    git \
    ca-certificates \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create necessary directories and set permissions
RUN mkdir -p /etc/janus /usr/local/lib/janus/loggers /etc/recordingsdir
RUN chown -R root:root /etc/janus /usr/local/lib/janus/loggers /etc/recordingsdir
RUN chmod -R 755 /etc/janus /usr/local/lib/janus/loggers /etc/recordingsdir

# Copy Janus Gateway source code
COPY ./janus_gateway_code /opt/janus-gateway
COPY . /opt/janus-gateway
COPY config/janus.jcfg /usr/local/etc/janus/janus.jcfg


WORKDIR /opt/janus-gateway

# Build Janus from source
RUN sh autogen.sh && \
    ./configure --disable-docs && \
    make && \
    make install && \
    make configs && \
    ldconfig

# Copy configuration files and entrypoint
COPY config/janus.jcfg /usr/local/etc/janus/janus.jcfg
COPY entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod 644 /usr/local/etc/janus/janus.jcfg
RUN chmod +x /entrypoint.sh

# Expose necessary ports
EXPOSE 8088 8089 8188 8189

# Run Janus Gateway
CMD ["/entrypoint.sh"]
