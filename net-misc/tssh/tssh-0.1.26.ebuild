# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

MY_PN="trzsz-ssh"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="SSH client with a server selection menu and trzsz file transfer"
HOMEPAGE="https://github.com/trzsz/trzsz-ssh https://trzsz.github.io/ssh"
SRC_URI="
	https://github.com/trzsz/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/${PN}/releases/download/v${PV}/${P}-vendor.tar.xz
"
S="${WORKDIR}/${MY_P}"

LICENSE="MIT Apache-2.0 BSD BSD-2 ISC MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=dev-lang/go-1.25.0:="

src_compile() {
	ego build -buildvcs=false -trimpath -o "${T}/${PN}" ./cmd/tssh
}

src_test() {
	# internal/table expects text without the escapes the code emits; upstream's
	# own make test runs ./tssh alone.
	ego test ./tssh
}

src_install() {
	dobin "${T}/${PN}"
	dodoc README.md README.cn.md README.en.md
}
