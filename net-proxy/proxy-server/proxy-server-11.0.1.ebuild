# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# every file the cmake<4 compat check flags sits in a third_party test, example or
# IDE directory that nothing add_subdirectory's. this also hides upstream's own
# top-level cmake_minimum_required(VERSION 3.5), which has to be fixed upstream
CMAKE_QA_COMPAT_SKIP=1

inherit cmake

DESCRIPTION="Implementation of all proxy protocols using modern c++"
HOMEPAGE="https://github.com/jackarain/proxy"
SRC_URI="https://github.com/Jackarain/proxy/archive/refs/tags/v${PV}.tar.gz -> proxy-${PV}.tar.gz"
S="${WORKDIR}/proxy-${PV}"

# MIT covers third_party/fmt, which is built in
LICENSE="Boost-1.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-libs/openssl:=
	virtual/zlib:=
"
DEPEND="${RDEPEND}"

src_prepare() {
	# upstream adds -static-libstdc++ unconditionally and offers no switch for it,
	# so a libstdc++ ABI fix would never reach the installed binary
	sed -i -e 's/ -static-libstdc++//g' CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		# upstream vendors openssl and zlib under third_party and builds them by
		# default; boost and fmt stay bundled, upstream add_subdirectory's them
		# unconditionally and offers no system switch
		-DENABLE_SYSTEM_OPENSSL=ON
		-DENABLE_SYSTEM_ZLIB=ON
		# a release tarball has no .git, and this would run git in ${S}
		-DENABLE_GIT_VERSION=OFF
		-DENABLE_STATIC_LINK_TO_GCC=OFF
	)
	cmake_src_configure
}
