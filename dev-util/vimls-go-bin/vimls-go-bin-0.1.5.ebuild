# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Language server for Legacy Vim script and Vim9 script"
HOMEPAGE="https://github.com/neoclide/vimls-go"
SRC_URI="
	amd64? ( https://github.com/neoclide/vimls-go/releases/download/v${PV}/vimls-v${PV}-linux-amd64.tar.gz )
	arm64? ( https://github.com/neoclide/vimls-go/releases/download/v${PV}/vimls-v${PV}-linux-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="MIT vim"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/vimls"

src_install() {
	dobin vimls
	dodoc README.md CHANGELOG.md docs/language-support.md
	dodoc -r LICENSES
}
