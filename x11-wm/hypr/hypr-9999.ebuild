# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 toolchain-funcs

DESCRIPTION="A dynamic Linux tiling window manager for Xorg"
HOMEPAGE="https://github.com/hyprwm/Hypr"
EGIT_REPO_URI="https://github.com/hyprwm/Hypr.git"

LICENSE="BSD"
SLOT="0"

RDEPEND="
	dev-cpp/gtkmm:3.0
	dev-libs/glib:2
	media-libs/harfbuzz:=
	x11-libs/cairo
	x11-libs/libxcb:=
	x11-libs/xcb-util
	x11-libs/xcb-util-cursor
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-wm
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=( "${FILESDIR}"/${PN}-1.1.4-conversion-null.patch )

pkg_pretend() {
	if ! tc-is-gcc; then
		ewarn "Only GCC is officially supported as compiler"
		ewarn "Proceed with your own caution"
	fi
	}

src_prepare() {
	# respect CXX and CXXFLAGS
	sed -e '/CMAKE_CXX_COMPILER/d' -e '/-Ofast/d' \
		-e '/cmake_minimum_required/s/3\.5/3.10/' -i CMakeLists.txt || die
	cmake_src_prepare
}

src_install() {
	dobin "${BUILD_DIR}/Hypr"
	dodoc "${S}/example/hypr.conf"
}
