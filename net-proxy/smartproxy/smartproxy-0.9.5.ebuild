# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

# workaround for compatibility with cmake 4, bugs #951350
CMAKE_QA_COMPAT_SKIP=yes

DESCRIPTION="A fast, proxy smart selector"
HOMEPAGE="https://github.com/microcai/smartproxy"
SRC_URI="
	https://github.com/microcai/smartproxy/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="dev-libs/openssl"
RDEPEND="${DEPEND}"

src_configure(){
	local mycmakeargs=(
		-DUSE_SYSTEM_OPENSSL=ON
		-DUSE_SYSTEM_BOOST=OFF
		-DCMAKE_POLICY_VERSION_MINIMUM=3.5 # bugs #951350
	)
	cmake_src_configure
}
