# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y autoconf automake libboost-all-dev libpcap-dev clang make

ADD . /justniffer
WORKDIR /justniffer

## Build
RUN ./configure
RUN  make -j$(nproc)

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libstdc++6 libgcc-s1 libicu66 zlib1g libbz2-1.0 liblzma5 libzstd1 libpcap0.8 libboost-regex1.71.0 libboost-iostreams1.71.0 libboost-program-options1.71.0 

COPY --from=builder /justniffer/src/justniffer /justniffer
