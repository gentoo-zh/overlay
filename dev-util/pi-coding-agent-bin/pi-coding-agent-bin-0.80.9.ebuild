# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A terminal-based coding agent with multi-model support"
HOMEPAGE="https://github.com/badlogic/pi-mono"
SRC_URI="
	amd64? ( https://github.com/badlogic/pi-mono/releases/download/v${PV}/pi-linux-x64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/badlogic/pi-mono/releases/download/v${PV}/pi-linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"/pi

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="+system-fd"
RESTRICT="bindist strip"

RDEPEND="
	system-fd? ( sys-apps/fd )
"

QA_PREBUILT="opt/${PN}/pi"

src_install() {
	insinto /opt/${PN}
	doins -r .
	fperms +x /opt/${PN}/pi

	dosym ../${PN}/pi /opt/bin/pi
}
