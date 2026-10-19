# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A Material Design-like skin for Fcitx"
HOMEPAGE="https://github.com/hrko/fcitx-skin-material"
SRC_URI="https://github.com/hrko/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RDEPEND="app-i18n/fcitx"

src_install() {
	insinto /usr/share/fcitx5/themes/material
	doins material/*
}

pkg_postinst() {
	elog "To use the theme, you'll need to create '~/.config/fcitx5/conf/classicui.conf'"
	elog "with the following content: "
	elog "	Theme=material"
	elog "	# depends on your preference"
	elog "	Vertical Candidate List=True"
	elog "	Font=\"Sans Serif 12\""
	elog "Restart fcitx5 to make the config take effect"
}
