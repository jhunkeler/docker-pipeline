#!/bin/bash
set -e
set -x

# Uses GLOBAL environment variable: PYTHON_VERSION defined by `docker build` argument
prefix="${TOOLCHAIN}"
sysconfdir="${TOOLCHAIN_BUILD}/etc/${PIPELINE}"
reqdir=${sysconfdir}/pip

export PATH="${prefix}/bin:${PATH}"
export CFLAGS="-I${prefix}/include"
export LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"

function pre()
{
    if [[ ! -d ${reqdir} ]]; then
        # Nothing there, but maybe that's on purpose.
        exit 0
    fi
}

function build()
{
    pre
    # Iterate over pip requirement files
    for req in ${reqdir}/*
    do
        pip install --upgrade --progress-bar=off -r "${req}"
    done
    post
}

function post()
{
    rm -rf ~/.cache/pip
    [[ -d src ]] && rm -rf src || true
    [[ -f gmon.out ]] && rm -rf gmon.out || true
}

build
