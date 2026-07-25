# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=fcitx5-table-dayi

inherit cmake git-r3 xdg

DESCRIPTION="Dayi (大易) table input method for Fcitx5"
HOMEPAGE="https://github.com/fcitx/fcitx5-table-dayi"
EGIT_REPO_URI="https://github.com/fcitx/fcitx5-table-dayi.git"

LICENSE="dayi"
SLOT="5"
KEYWORDS=""

DEPEND="
	app-i18n/fcitx:5
	app-i18n/libime
"
RDEPEND="${DEPEND}"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${P}-cmake_316.patch
)
