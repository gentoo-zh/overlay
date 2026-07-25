# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 xdg

MY_PN="fcitx5-hallelujah"
DESCRIPTION="English word-completion (prediction) input method for Fcitx5"
HOMEPAGE="https://github.com/fcitx-contrib/fcitx5-hallelujah"
EGIT_REPO_URI="https://github.com/fcitx-contrib/${MY_PN}.git"

LICENSE="GPL-3"
SLOT="5"
KEYWORDS=""
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	>=app-i18n/fcitx-5.1.13:5[enchant]
	dev-cpp/nlohmann_json
	dev-libs/libfmt:=
	dev-libs/marisa
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-libs/marisa[tools(+)]
	kde-frameworks/extra-cmake-modules:0
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	# Live upstream declares cmake_minimum_required 3.6; raise it past ECM's
	# compatibility threshold so it stops warning.
	sed -i -e '/cmake_minimum_required/s/VERSION 3\.6/VERSION 3.16/' CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_TEST=$(usex test)
	)
	cmake_src_configure
}
