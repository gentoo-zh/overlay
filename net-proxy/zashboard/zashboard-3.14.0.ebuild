# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The Official Mihomo Dashboard"
HOMEPAGE="https://github.com/Zephyruso/zashboard"
SRC_URI="
	https://github.com/Zephyruso/zashboard/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-node_modules.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	net-libs/nodejs[npm]
	dev-vcs/git
"

src_compile() {
	npm run build || die
}

src_install() {
	insinto /usr/share/"${PN}"
	doins -r dist/*
}
