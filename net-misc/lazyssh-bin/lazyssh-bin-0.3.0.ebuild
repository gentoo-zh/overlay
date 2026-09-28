# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Terminal UI for managing SSH connections"
HOMEPAGE="https://github.com/Adembc/lazyssh"
BASE_URI="https://github.com/Adembc/lazyssh/releases/download/v${PV}/lazyssh_Linux"
SRC_URI="
	amd64? ( ${BASE_URI}_x86_64.tar.gz -> ${P}_Linux_x86_64.tar.gz )
	arm64? ( ${BASE_URI}_arm64.tar.gz -> ${P}_Linux_arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	amd64? ( >=sys-libs/glibc-2.34 )
	net-misc/openssh
"
RESTRICT="strip"

src_install() {
	dobin lazyssh
	dodoc LICENSE README.md
}
