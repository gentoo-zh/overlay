# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="fcitx5-zhuyin"
inherit cmake unpacker xdg

DESCRIPTION="Zhuyin (Bopomofo) input method for Fcitx5 based on libzhuyin"
HOMEPAGE="https://github.com/fcitx/fcitx5-zhuyin"
# The _dict tarball bundles the libzhuyin language model under data/, so the
# cmake build finds it locally instead of downloading it.
SRC_URI="https://download.fcitx-im.org/fcitx5/${MY_PN}/${MY_PN}-${PV}_dict.tar.zst"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="GPL-2+"
SLOT="5"
KEYWORDS="~amd64"

PATCHES=(
	"${FILESDIR}"/${P}-cmake_316.patch
)

DEPEND="
	>=app-i18n/fcitx-5.1.13:5
	app-i18n/libpinyin
"
RDEPEND="${DEPEND}"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	sys-devel/gettext
"
