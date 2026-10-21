# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake git-r3 xdg

DESCRIPTION="windows applications setup wizard for Chinese wine users"
HOMEPAGE="https://github.com/hillwoodroc/winetricks-zh/"

EGIT_REPO_URI="https://github.com/hillwoodroc/winetricks-zh.git"

LICENSE="LGPL-2.1+"
SLOT="0"

RDEPEND="app-emulation/winetricks"

src_prepare() {
	# ensure cmake_minimum_required >=3.10 (Bug: 951350)
	sed -e '/cmake_minimum_required/s/2\.6/3.10/' -i CMakeLists.txt || die
	cmake_src_prepare
}
