# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="UDP-based SSH server with roaming support"
HOMEPAGE="https://github.com/trzsz/tsshd https://trzsz.github.io/tsshd"
SRC_URI="
	https://github.com/trzsz/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/tsshd/releases/download/v${PV}/${P}-vendor.tar.xz
"

LICENSE="Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

# Upstream requires Go 1.25.9 or newer.
BDEPEND=">=dev-lang/go-1.25.9:="

src_compile() {
	ego build -buildvcs=false -trimpath -o "${T}/${PN}" ./cmd/tsshd
}

src_install() {
	dobin "${T}/${PN}"
	dodoc README.md README.cn.md
}
