# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Run common networking tests against any site"
HOMEPAGE="https://github.com/ycd/dstp"
SRC_URI="
	https://github.com/ycd/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-deps.tar.xz
"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="!net-analyzer/dstp-bin"

src_compile() {
	ego build -o ${PN} ./cmd/${PN}
}

src_test() {
	ego test ./...
}

src_install() {
	dobin ${PN}
	dodoc README.md
}
