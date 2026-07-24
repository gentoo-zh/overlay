# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Flutter SDK (prebuilt), for building Flutter applications from source"
HOMEPAGE="https://flutter.dev/"
SRC_URI="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${PV}-stable.tar.xz"
S="${WORKDIR}/flutter"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="mirror strip"

# Prebuilt Dart VM and Flutter engine binaries live under bin/cache.
QA_PREBUILT="*"

RDEPEND="sys-libs/glibc"

# The flutter tool writes a lockfile under bin/cache even for `flutter --version`, so the SDK
# cannot be invoked from its read-only install path and this package ships no /usr/bin wrapper.
# A consumer DEPENDs on it and copies /opt/flutter into its own writable build tree first; see
# net-misc/rustdesk for the pattern.

src_prepare() {
	default
	# Windows launchers are useless on Linux.
	rm -f bin/*.bat || die
}

src_install() {
	dodir /opt
	cp -a "${S}" "${ED}"/opt/flutter || die
}
