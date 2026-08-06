# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Run common networking tests against any site"
HOMEPAGE="https://github.com/ycd/dstp"
SRC_URI="
	amd64? ( https://github.com/ycd/dstp/releases/download/v${PV}/dstp_${PV}_Linux_amd64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/ycd/dstp/releases/download/v${PV}/dstp_${PV}_Linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
"

S="${WORKDIR}"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="!net-analyzer/dstp"

src_install() {
	dobin dstp
	dodoc README.md
}
