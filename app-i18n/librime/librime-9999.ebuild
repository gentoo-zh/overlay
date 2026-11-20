# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic git-r3 multiprocessing

DESCRIPTION="RIME (Rime Input Method Engine) core library"
HOMEPAGE="https://rime.im/ https://github.com/rime/librime"
EGIT_REPO_URI="https://github.com/rime/librime.git"
EGIT_SUBMODULES=( deps/spdlog )

LICENSE="BSD BSD-2 Boost-1.0 MIT"
SLOT="0/1-9999"
KEYWORDS=""
IUSE="debug test"
RESTRICT="!test? ( test )"

RDEPEND="
	app-i18n/opencc:=
	dev-cpp/yaml-cpp:=
	>=dev-libs/boost-1.74:=
	dev-libs/leveldb:=
	dev-libs/marisa
"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )
"

DOCS=( CHANGELOG.md README.md )

src_configure() {
	# -Werror=odr
	# https://bugs.gentoo.org/944741
	# https://github.com/rime/librime/issues/954
	filter-lto

	if use debug; then
		local CMAKE_BUILD_TYPE=Debug
	else
		append-cxxflags -DNDEBUG
	fi

	local mycmakeargs=(
		-DBUILD_TEST=$(usex test)
		-DCMAKE_BUILD_PARALLEL_LEVEL=$(makeopts_jobs)
		-DENABLE_EXTERNAL_PLUGINS=ON
		-DINSTALL_PRIVATE_HEADERS=ON
	)
	cmake_src_configure
}
