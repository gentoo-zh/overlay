# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion

DESCRIPTION="A cross-platform version manager, extendable via plugins"
HOMEPAGE="https://vfox.dev https://github.com/version-fox/vfox"
SRC_URI="
	https://github.com/version-fox/vfox/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/vfox/releases/download/v${PV}/${P}-vendor.tar.xz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

RDEPEND="app-shells/bash"
RDEPEND+=" !dev-util/vfox-bin"
BDEPEND=">=dev-lang/go-1.24.0"

src_compile() {
	ego build -o ${P}
}

src_install() {
	newbin ${P} ${PN}

	dodoc README.md

	newbashcomp completions/bash_autocomplete ${PN}
	newzshcomp completions/zsh_autocomplete _${PN}
}
