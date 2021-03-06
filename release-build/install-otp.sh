#!/bin/bash

# Download, build and install a given version of OTP into
# #HOME/otp-VERSION

set -e -x

version=$1
extras=$2

if [ $(uname -s) = 'Darwin' ]; then
    # Use OpenSSL from Homebrew.
    with_ssl='--with-ssl=/usr/local/opt/openssl'
fi

if [ ! -f $HOME/otp-$version/.ok ] ; then
    rm -rf $HOME/otp-$version/.ok
    mkdir -p $HOME/tmp-otp-build
    cd $HOME/tmp-otp-build
    rm -rf otp_$version
    git clone https://github.com/erlang/otp.git --branch OTP-$version otp_$version
    cd otp_$version
    { ./otp_build autoconf && touch .autoconf-ok ; } | tee $HOME/tmp-otp-build/otp-$version.log
    test -e .autoconf-ok
    { ./configure --prefix=$HOME/otp-$version $with_ssl $extras 2>&1 && touch .configure-ok ; } | tee -a $HOME/tmp-otp-build/otp-$version.log
    test -e .configure-ok
    { make 2>&1 && touch .make-ok ; } | tee -a $HOME/tmp-otp-build/otp-$version.log
    test -e .make-ok
    { make install 2>&1 && touch .make-install-ok ; } | tee -a $HOME/tmp-otp-build/otp-$version.log
    test -e .make-install-ok
    cd $HOME/tmp-otp-build
    rm -rf otp_$version
    touch $HOME/otp-$version/.ok
fi
