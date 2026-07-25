# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 xdg

MY_PN="fcitx5-quwei"
DESCRIPTION="Quwei (区位) input method for Fcitx5"
HOMEPAGE="https://github.com/fcitx/fcitx5-quwei"
EGIT_REPO_URI="https://github.com/fcitx/${MY_PN}.git"

LICENSE="BSD"
SLOT="5"
KEYWORDS=""

DEPEND="
	>=app-i18n/fcitx-5.1.0:5
	app-i18n/fcitx-chinese-addons:5
"
RDEPEND="${DEPEND}"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	sys-devel/gettext
"
