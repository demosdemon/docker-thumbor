#!/usr/bin/env bash

set -eux

PKGS=(
    build-essential
    git
    # graphicsmagick
    libcurl4-openssl-dev
    # libfreetype6-dev
    # libfribidi-dev
    # libgraphicsmagick-q16-3
    libgraphicsmagick++1-dev
    # libgraphicsmagick++3
    # libharfbuzz-dev
    # libjpeg-turbo-progs
    libjpeg62-turbo-dev
    liblcms2-dev
    libmemcached-dev
    # libopenjp2-7-dev
    libssh2-1-dev
    libssl-dev
    libtiff5-dev
    # libwebp-dev
    # libxcb1-dev
    # tcl8.6-dev
    # tk8.6-dev
)

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)

CMD=$(cat <<"EOF"
#!/usr/bin/env bash
awk '$1 ~ "^deb" { $3 = $3 "-backports"; print; exit }' /etc/apt/sources.list > /etc/apt/sources.list.d/backports.list;
apt-get update;
apt-get upgrade -y;
apt-get autoremove -y;
apt-get install --no-install-recommends -y "$@";
apt-get clean;

pip install -U pipenv pip-tools "clikit<0.5.0,>=0.4.2" poetry

pip-compile --rebuild --verbose --header --annotate --upgrade --allow-unsafe
EOF
)

exec docker run -v "${ROOT}:/src" --workdir /src --rm "${IMAGE_PREFIX:-minimalcompact}/python-boost" bash -c "$CMD" -- "${PKGS[@]}"
