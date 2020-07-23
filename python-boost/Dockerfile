FROM python:3.8-slim

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install --no-install-recommends -y \
        build-essential \
        curl \
        libbz2-dev \
        libicu-dev \
        liblzma-dev \
        libzstd-dev \
        zlib1g-dev \
    ; \
    apt-get clean; \
    \
# We have to compile boost ourselves against the docker Python and cannot use Debian package.
    cd /usr/src; \
    curl -fsSLO --compressed --retry 3 https://dl.bintray.com/boostorg/release/1.73.0/source/boost_1_73_0.tar.gz; \
    tar xzf boost_1_73_0.tar.gz; \
    cd boost_1_73_0; \
    ./bootstrap.sh --with-python="$(which python3)"; \
    ./b2 install; \
    cd /; \
    ldconfig; \
    rm -rf /usr/src/*; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*;
