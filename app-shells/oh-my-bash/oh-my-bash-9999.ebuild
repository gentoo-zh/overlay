# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="An open source, community-driven framework for managing your bash configuration"
HOMEPAGE="https://ohmybash.nntoan.com/"

EGIT_REPO_URI="https://github.com/ohmybash/oh-my-bash.git"

LICENSE="MIT"
SLOT="0"

PATCHES=( "${FILESDIR}/${P}-custom-upgrade.patch" )

src_prepare() {
	sed -i -e 's|~/.oh-my-bash|/usr/share/oh-my-bash|' templates/bashrc.osh-template || die
	default
}

src_install() {
	insinto /usr/share/oh-my-bash
	doins -r *
}

pkg_postinst() {
	elog "In order to use oh-my-bash, copy /usr/share/oh-my-bash/templates/bashrc.osh-template over to your ~/.bashrc"
}
