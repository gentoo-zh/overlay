# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Inspect, grade, and manage certificates and TLS from the terminal"
HOMEPAGE="https://github.com/glincker/sslx"
SRC_URI="
	amd64? ( https://github.com/glincker/sslx/releases/download/v${PV}/sslx-linux-x86_64 -> ${P}-amd64 )
	arm64? ( https://github.com/glincker/sslx/releases/download/v${PV}/sslx-linux-aarch64 -> ${P}-arm64 )
	https://raw.githubusercontent.com/glincker/sslx/v${PV}/LICENSE -> ${P}-LICENSE
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/sslx"

src_install() {
	newbin "${DISTDIR}/${P}-${ARCH}" sslx
	newdoc "${DISTDIR}/${P}-LICENSE" LICENSE
}
