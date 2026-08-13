# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A collection of plasma weather ions for Chinese users"
HOMEPAGE="https://github.com/arenekosreal/plasma-ions-china"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/arenekosreal/plasma-ions-china.git"
else
	SRC_URI="https://github.com/arenekosreal/plasma-ions-china/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"

RDEPEND="
	dev-qt/qtbase:6
	>=kde-plasma/kdeplasma-addons-6.7:6
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
	kde-frameworks/extra-cmake-modules
"

src_configure() {
	local mycmakeargs=( -DPLASMA_IONS_CHINA_USE_SYSTEM_HEADERS=ON )
	if [[ ${PV} != *9999* ]]; then
		mycmakeargs+=( -DPLASMA_IONS_CHINA_VERSION="${PV}" )
	fi
	cmake_src_configure
}
