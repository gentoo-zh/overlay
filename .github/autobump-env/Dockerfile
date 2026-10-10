ARG BASE
FROM ${BASE}

RUN emerge-webrsync --no-pgp-verify \
 && { \
      echo 'FEATURES="${FEATURES} getbinpkg buildpkg"'; \
      echo 'PORTAGE_ELOG_CLASSES="qa warn error"'; \
      echo 'PORTAGE_ELOG_SYSTEM="save"'; \
      echo 'ACCEPT_LICENSE="*"'; \
    } >> /etc/portage/make.conf \
 && mkdir -p /etc/portage/package.use \
 # ci-binhost USE must match the binhost or getbinpkg rejects its binpkgs.
 && printf '%s\n' 'dev-qt/qtwebengine bindist' 'net-libs/webkit-gtk keyring' \
      > /etc/portage/package.use/ci-binhost \
 # Xvfb runs the GUI launch probe.
 && echo 'x11-base/xorg-server xvfb minimal -xorg' > /etc/portage/package.use/autobump-xvfb \
 && getuto \
 && install -dm775 -o root -g portage /var/cache/distfiles \
 # curl supplies the DeadUrl recheck (stage3 has only wget); portage-utils supplies --version smoke, iwdevtools qa-vdb.
 && emerge --quiet --getbinpkg --autounmask=y --autounmask-write=y --autounmask-continue=y \
      dev-lang/ruby dev-vcs/git dev-util/pkgdev dev-util/pkgcheck app-portage/portage-utils \
      app-portage/iwdevtools dev-util/github-cli app-misc/jq net-misc/curl \
      app-portage/cpuid2cpuflags x11-base/xorg-server \
 && rm -rf /var/db/repos/gentoo /var/cache/distfiles/* /var/cache/binpkgs/*
