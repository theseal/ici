FROM debian:stable AS build
ARG VERSION

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && apt-get -y install \
    devscripts \
    git \
    help2man \
    softhsm2
COPY . /build/ici-${VERSION}
RUN mv /build/ici-${VERSION}/ici-${VERSION}.tar.gz /build/ici_${VERSION}.orig.tar.gz
WORKDIR /build/ici-${VERSION}
RUN (git describe; git log -n 1) > /build/revision.txt
RUN rm -rf ca .git
RUN dpkg-buildpackage -b
RUN find /build -type f -name '*.deb' -ls

FROM debian:stable
ARG VERSION
COPY --from=build /build/ici_${VERSION}-*.deb /build/revision.txt /
COPY scripts/inotify_issue_and_publish.sh /
COPY scripts/init_softhsm_ca.sh /

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && apt-get -y install \
    inotify-tools \
    git \
    libengine-pkcs11-openssl1.1 \
    opensc \
    openssl \
    softhsm2
RUN ls -l /ici_${VERSION}-*.deb
RUN dpkg -i /ici_${VERSION}-*.deb

VOLUME ["/var/lib/ici", "/var/lib/softhsm"]
ENTRYPOINT ["/bin/bash"]
