# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git autoconf automake libboost-all-dev libpcap-dev clang make

## Add source code to the build stage. ADD prevents git clone being cached when it shouldn't
WORKDIR /
ADD https://api.github.com/repos/capuanob/justniffer/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/capuanob/justniffer.git
WORKDIR /justniffer

## Build
RUN ./configure
RUN  make -j$(nproc)

## Prepare all library dependencies for copy
RUN mkdir /deps
RUN cp `ldd ./src/justniffer | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
RUN mkdir -p /tests
COPY --from=builder /justniffer/src/justniffer /justniffer
COPY --from=builder /justniffer/test/*.cap /tests
COPY --from=builder /deps /usr/lib

CMD ["/justniffer", "-f", "@@"]
