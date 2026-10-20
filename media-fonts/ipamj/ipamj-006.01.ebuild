# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="IPAmj 明朝 (IPAmj Mincho) font"
HOMEPAGE="https://moji.or.jp/mojikiban/font/"
MY_PV="${PV//./}"
SRC_URI="https://dforest.watch.impress.co.jp/library/i/ipamjfont/10750/ipamjm${MY_PV}.zip -> ${P}.zip"

S="${WORKDIR}"
LICENSE="IPAfont"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
BDEPEND="app-arch/unzip"
FONT_S="${S}"
FONT_SUFFIX="ttf"
RESTRICT="mirror"
