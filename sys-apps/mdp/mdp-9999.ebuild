# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit git-r3 toolchain-funcs

DESCRIPTION="A command-line based markdown presentation tool"
HOMEPAGE="https://github.com/visit1985/mdp"

EGIT_REPO_URI="https://github.com/visit1985/mdp.git"

LICENSE="GPL-3+"
SLOT="0"

RDEPEND="sys-libs/ncurses:="
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_compile() {
	export CPPFLAGS+=" $($(tc-getPKG_CONFIG) --cflags ncursesw)"
	emake CC="$(tc-getCC)" LDLIBS="$($(tc-getPKG_CONFIG) --libs ncursesw)"
}

src_install() {
	dobin mdp
}
