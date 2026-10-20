# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A general-purpose Qt-based library aimed at graph-controlled data processing"
HOMEPAGE="https://github.com/Qv2ray/QNodeEditor"
GIT_COMMIT="808a7cf0359771a474db17a82cbf631746d8735d"
SRC_URI="https://github.com/Qv2ray/QNodeEditor/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/QNodeEditor-${GIT_COMMIT}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-qt/qtbase:6[widgets,gui]"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-qt6.patch"
)

src_prepare() {
	# ensure cmake_minimum_required >=3.10 (Bug: 951350)
	sed -e '/cmake_minimum_required/s/3\.2/3.10/' -i CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_EXAMPLES=OFF
	)
	cmake_src_configure
}
