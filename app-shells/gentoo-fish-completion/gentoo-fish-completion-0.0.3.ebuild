# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="Gentoo specific fish completion support (ported from gentoo-zsh-completions)"
HOMEPAGE="https://github.com/douglarek/gentoo-fish-completion"
SRC_URI="https://github.com/douglarek/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="app-shells/fish"

src_install() {
	insinto /usr/share/fish/vendor_functions.d
	doins functions/*.fish

	dofishcomp completions/*.fish
}
