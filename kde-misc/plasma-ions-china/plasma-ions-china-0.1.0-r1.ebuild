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
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-qt/qtbase:6
	>=kde-plasma/kdeplasma-addons-6.7:6
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
	kde-frameworks/extra-cmake-modules
"

PATCHES=( "${FILESDIR}/${PN}-0.1.0-package-version.patch" )

src_configure() {
	if [[ ${PV} == *9999* ]]; then
		local mycmakeargs=( -DPROJECT_VERSION="$(git rev-parse HEAD)" )
	else
		local mycmakeargs=( -DPROJECT_VERSION="${PV}" )
	fi
	mycmakeargs+=(
		-DPLASMA_IONS_CHINA_USE_SYSTEM_HEADERS=ON
	)
	cmake_src_configure
}
