# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

DESCRIPTION="A immich-CLI alternative"
HOMEPAGE="https://github.com/simulot/immich-go/"
SRC_URI="
	https://codeload.github.com/simulot/immich-go/tar.gz/v${PV} -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/immich-go/releases/download/v${PV}/${P}-vendor.tar.xz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.25"

src_compile() {
	ego build -ldflags "-X github.com/simulot/immich-go/app.Version=${PV}"
}

src_install() {
	dobin "${PN}"
}
