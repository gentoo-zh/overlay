# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 22 )

inherit flag-o-matic llvm-r2 cmake

DESCRIPTION="Module-first C++ build tool with manifest"
HOMEPAGE="https://github.com/litocpp/lito"

LIBSODIUM_TAG="1.0.22"
LUA_TAG="5.5.1"
RSTD_COMMIT="fdb99aaa894d76b04032cd301ac82b5ee6e3ec6d"
LUATO_COMMIT="61dd40dca1e9aeda69eed208ddf0d10b34f59db7"

SRC_URI="
	https://github.com/litocpp/lito/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://download.libsodium.org/libsodium/releases/libsodium-${LIBSODIUM_TAG}.tar.gz
	https://lua.org/ftp/lua-${LUA_TAG}.tar.gz
	https://github.com/litocpp/rstd/archive/${RSTD_COMMIT}.tar.gz -> rstd-${RSTD_COMMIT}.tar.gz
	https://github.com/litocpp/luato/archive/${LUATO_COMMIT}.tar.gz -> luato-${LUATO_COMMIT}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	llvm-runtimes/libcxx
	app-arch/zstd
"
RDEPEND="
	${DEPEND}
	dev-build/cmake
	dev-vcs/git
	llvm-core/clang
	llvm-core/lld
	net-misc/curl
"
BDEPEND="
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}=
		llvm-core/lld:${LLVM_SLOT}=
	')
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-0.6.1-use_system_zstd.patch"
)

src_configure() {
	export \
		CC="clang-${LLVM_SLOT}" \
		CXX="clang++-${LLVM_SLOT}"
	append-ldflags -fuse-ld=lld

	# the rstd module fails to build with FORTIFY_SOURCE
	# https://github.com/llvm/llvm-project/issues/121709
	append-cxxflags -D_FORTIFY_SOURCE=0

	local mycmakeargs=(
		-DCMAKE_LINKER_TYPE=LLD
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_SOURCE_DIR_SODIUM="${WORKDIR}/libsodium-${LIBSODIUM_TAG}"
		-DFETCHCONTENT_SOURCE_DIR_LUA="${WORKDIR}/lua-${LUA_TAG}"
		-DFETCHCONTENT_SOURCE_DIR_RSTD="${WORKDIR}/rstd-${RSTD_COMMIT}"
		-DFETCHCONTENT_SOURCE_DIR_LUATO="${WORKDIR}/luato-${LUATO_COMMIT}"
		-DLITO_USE_SYSTEM_ZSTD=ON
	)

	cmake_src_configure
}
