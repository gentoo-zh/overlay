# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Command-line client for the paste.gentoozh.org pastebin"
HOMEPAGE="https://github.com/gentoo-zh/gzpaste"
SRC_URI="https://github.com/gentoo-zh/gzpaste/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"

RDEPEND="net-misc/curl"

src_install() {
	dobin gzpaste
	dodoc README.md README.zh-CN.md README.zh-TW.md
}
