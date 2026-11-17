# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="Pacstrap - install packages to the specified new root directorye"
HOMEPAGE="https://github.com/archlinux/arch-install-scripts https://man.archlinux.org/man/pacstrap.8"
SRC_URI="https://gitlab.archlinux.org/archlinux/arch-install-scripts/-/archive/v${PV}/arch-install-scripts-v${PV}.tar.bz2"

S="${WORKDIR}/arch-install-scripts-v${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	app-alternatives/awk
	app-text/asciidoc
"
RDEPEND="sys-apps/pacman"

src_test() {
	emake MANS="doc/pacstrap.8" BINPROGS="pacstrap" check
}

src_compile() {
	emake MANS="doc/pacstrap.8" BINPROGS="pacstrap"
}

src_install() {
	dobin pacstrap
	doman doc/pacstrap.8
	newbashcomp completion/bash/pacstrap pacstrap
	newzshcomp completion/zsh/_pacstrap _pacstrap
}
