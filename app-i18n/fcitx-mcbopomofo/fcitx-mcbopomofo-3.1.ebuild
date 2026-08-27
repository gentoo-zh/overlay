# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="fcitx5-mcbopomofo"
inherit cmake xdg

DESCRIPTION="McBopomofo (Traditional Chinese phonetic) input method for Fcitx5"
HOMEPAGE="https://github.com/openvanilla/fcitx5-mcbopomofo"
SRC_URI="https://github.com/openvanilla/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="5"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	>=app-i18n/fcitx-5.1.0:5
	dev-libs/json-c:=
	dev-libs/libfmt:=
"
RDEPEND="${DEPEND}"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	sys-devel/gettext
	virtual/pkgconfig
	test? ( dev-cpp/gtest )
"

src_prepare() {
	# Every CMakeLists declares an old cmake_minimum_required (3.10/3.12);
	# raise past ECM's 3.16 compatibility warning threshold.
	find . -name CMakeLists.txt -exec \
		sed -i -E '/cmake_minimum_required/s/VERSION [0-9.]+/VERSION 3.16/' {} + || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		# Build the internal engine libraries statically so their symbols
		# (hidden by -fvisibility=hidden) link into the addon module instead
		# of separate, uninstalled .so files.
		-DBUILD_SHARED_LIBS=OFF
		-DENABLE_TEST=$(usex test)
	)
	cmake_src_configure
}
