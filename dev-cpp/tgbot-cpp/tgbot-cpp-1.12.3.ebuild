# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C++ library for Telegram bot API"
HOMEPAGE="https://github.com/reo7sp/tgbot-cpp"
SRC_URI="https://github.com/reo7sp/tgbot-cpp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+shared-libs doc test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-cpp/nlohmann_json-3.7.3
	>=dev-libs/boost-1.65.1
	>=net-misc/curl-7.58.0:="
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )"
BDEPEND="doc? ( app-text/doxygen[dot] )"

src_configure() {
	mycmakeargs=(
		-DENABLE_TESTS=$(usex test ON OFF)
		-DBUILD_SHARED_LIBS=$(usex shared-libs ON OFF)
		-DBUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON
	)
	cmake_src_configure
}
