# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

DESCRIPTION="An offline tool for querying IP geographic information and CDN provider"
HOMEPAGE="https://github.com/zu1k/nali"
EGIT_COMMIT="1651b7a17cd6b4fce3942d024891af64d2bdac84"
SRC_URI="
	https://github.com/zu1k/nali/archive/${EGIT_COMMIT}.tar.gz -> ${P}.gh.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-vendor.tar.xz
"

S="${WORKDIR}/${PN}-${EGIT_COMMIT}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
BDEPEND=">=dev-lang/go-1.26.0"

src_compile() {
	local ldflags="
		-X github.com/zu1k/nali/internal/constant.Version=${PV}
		"
	ego build -ldflags "${ldflags}"
}

src_install() {
	dobin ${PN}
}
