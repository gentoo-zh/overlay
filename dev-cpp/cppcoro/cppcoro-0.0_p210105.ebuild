# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A library of C++ coroutine abstractions for the coroutines TS"
HOMEPAGE="https://github.com/Garcia6l20/cppcoro"
COMMIT_ID="e1d53e620b0eee828915ada179cd7ca8e66ca855"
SRC_URI="https://github.com/Garcia6l20/cppcoro/archive/${COMMIT_ID}.tar.gz -> ${P}.gh.tar.gz"

S="${WORKDIR}/cppcoro-${COMMIT_ID}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# currently, test is broken
IUSE="+shared"
RESTRICT="test"

PATCHES=(
	"${FILESDIR}"/${PN}-ins-into-lib64.patch
	"${FILESDIR}"/${PN}-include-utility.patch
)

src_configure() {
	mycmakeargs=(
		-DBUILD_TESTING=OFF
		-DBUILD_SHARED_LIBS=$(usex shared ON OFF)
	)
	cmake_src_configure
}
