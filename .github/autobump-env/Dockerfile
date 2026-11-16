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
 # Our binhost carries webkit-gtk[keyring] for -systemd too, which the Gentoo binhost often lacks after a release.
 && printf '[gentoo-zh-binhost]\nsync-uri = https://distfiles.gentoozh.org/binpkgs/x86-64\npriority = 2\n' \
      > /etc/portage/binrepos.conf/gentoo-zh.conf \
 && wget -q -O /tmp/gentoo-zh-binhost.asc https://distfiles.gentoozh.org/gentoo-zh-binhost.asc \
 && export GNUPGHOME=/etc/portage/gnupg \
 && gpg --import /tmp/gentoo-zh-binhost.asc \
 && gpg --batch --yes --pinentry-mode loopback --passphrase-file "$GNUPGHOME/pass" \
      --lsign-key 6A0726AF1476A2F382C6AC6638A0234EC16AD42E \
 && gpg --batch --check-trustdb \
 && unset GNUPGHOME \
 && install -dm775 -o root -g portage /var/cache/distfiles \
 # curl supplies the DeadUrl recheck (stage3 has only wget); portage-utils supplies --version smoke, iwdevtools qa-vdb.
 && emerge --quiet --getbinpkg --autounmask=y --autounmask-write=y --autounmask-continue=y \
      dev-lang/ruby dev-vcs/git dev-util/pkgdev dev-util/pkgcheck app-portage/portage-utils \
      app-portage/iwdevtools dev-util/github-cli app-misc/jq net-misc/curl \
      app-portage/cpuid2cpuflags sys-fs/squashfs-tools x11-base/xorg-server \
 && rm -rf /var/db/repos/gentoo /var/cache/distfiles/* /var/cache/binpkgs/*
