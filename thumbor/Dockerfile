ARG IMAGE_PREFIX=minimalcompact
FROM ${IMAGE_PREFIX}/python-boost

LABEL maintainer="MinimalCompact"

VOLUME /data

ENV HOME /app
ENV SHELL bash
ENV WORKON_HOME /app
WORKDIR /app

COPY requirements.txt requirements.txt

# TODO: these apt packages may still be needed
# graphicsmagick \
# libfreetype6-dev \
# libfribidi-dev \
# libgraphicsmagick-q16-3 \
# libgraphicsmagick++3 \
# libharfbuzz-dev \
# libjpeg-turbo-progs \
# libopenjp2-7-dev \
# libwebp-dev \
# libxcb1-dev \
# tcl8.6-dev \
# tk8.6-dev \

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    awk '$1 ~ "^deb" { $3 = $3 "-backports"; print; exit }' /etc/apt/sources.list > /etc/apt/sources.list.d/backports.list; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get autoremove -y; \
    apt-get install --no-install-recommends -y \
        build-essential \
        curl \
        git \
        libcurl4-openssl-dev \
        libgraphicsmagick++1-dev \
        libmemcached-dev \
        libssh2-1-dev \
        libssl-dev \
        libcairo2-dev \
        graphicsmagick \
    ; \
    apt-get clean; \
    \
    pip install --no-cache-dir -r requirements.txt; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual curl libcairo2 graphicsmagick $savedAptMark; \
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

ARG SIMD_LEVEL

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    awk '$1 ~ "^deb" { $3 = $3 "-backports"; print; exit }' /etc/apt/sources.list > /etc/apt/sources.list.d/backports.list; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get autoremove -y; \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        libcurl4-openssl-dev \
        libgraphicsmagick++1-dev \
        libjpeg62-turbo-dev \
        liblcms2-dev \
        libmemcached-dev \
        libssh2-1-dev \
        libssl-dev \
        libtiff5-dev \
    ; \
    apt-get clean; \
    \
# workaround for https://github.com/python-pillow/Pillow/issues/3441
# https://github.com/thumbor/thumbor/issues/1102
    PILLOW_VERSION=$(python -c 'import PIL; print(PIL.__version__)'); \
    if [ -z "${SIMD_LEVEL:-}" ]; then \
        CC="cc" && PILLOW_PACKET="pillow" && PILLOW_VERSION_SUFFIX=""; \
    else \
        CC="cc -m$SIMD_LEVEL" && PILLOW_PACKET="pillow-SIMD" && PILLOW_VERSION_SUFFIX=".post99"; \
    fi; \
    \
    { pip uninstall -y pillow || true; } && \
    CC=$CC \
# https://github.com/python-pillow/Pillow/pull/3241
    LIB=/usr/lib/x86_64-linux-gnu/ \
# https://github.com/python-pillow/Pillow/pull/3237 or https://github.com/python-pillow/Pillow/pull/3245
    INCLUDE=/usr/include/x86_64-linux-gnu/ \
    pip install --no-cache-dir -U --force-reinstall --no-binary=:all: "${PILLOW_PACKET}<=${PILLOW_VERSION}${PILLOW_VERSION_SUFFIX}" \
        --global-option="build_ext" --global-option="--debug" \
        --global-option="build_ext" --global-option="--enable-lcms" \
        --global-option="build_ext" --global-option="--enable-zlib" \
        --global-option="build_ext" --global-option="--enable-jpeg" \
        --global-option="build_ext" --global-option="--enable-tiff" \
    ; \
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

COPY conf/thumbor.conf.tpl /app/thumbor.conf.tpl
COPY conf/circus.ini.tpl /etc/circus.ini.tpl
COPY conf/thumbor-circus.ini.tpl /etc/circus.d/thumbor-circus.ini.tpl

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# running thumbor multiprocess via circus by default
# to override and run thumbor solo, set THUMBOR_NUM_PROCESSES=1 or unset it
CMD ["circus"]

EXPOSE 80 8888
