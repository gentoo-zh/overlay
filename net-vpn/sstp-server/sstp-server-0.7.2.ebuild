# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit systemd distutils-r1

DESCRIPTION="A Secure Socket Tunneling Protocol (SSTP) server implemented in Python"
HOMEPAGE="https://github.com/sorz/sstp-server/"
SRC_URI="https://github.com/sorz/sstp-server/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~mips ~x86"

DEPEND="net-dialup/ppp"

RDEPEND="${DEPEND}"

src_install(){
	distutils-r1_src_install

	insinto /etc/
	doins sstp-server.ini

	systemd_newunit "${FILESDIR}/sstp-server_at.service" sstp-server@.service
}
