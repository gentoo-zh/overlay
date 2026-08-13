# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
DISTUTILS_EXT=1
DISTUTILS_OPTIONAL=1
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 cmake multilib

DESCRIPTION="The Fast Cross-Platform Package Manager"
HOMEPAGE="https://github.com/mamba-org/mamba"
SRC_URI="https://github.com/mamba-org/mamba/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0/3"
KEYWORDS="~amd64"
IUSE="python mamba"
# Test requires network access
RESTRICT="test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="app-arch/libarchive:=
	app-arch/zstd:=
	dev-cpp/cli11
	dev-cpp/nlohmann_json
	dev-cpp/reproc:=
	dev-cpp/expected
	dev-cpp/yaml-cpp
	dev-libs/simdjson
	sys-libs/libsolv:=[conda]
	mamba? (
		app-crypt/mit-krb5
		app-arch/bzip2
		app-arch/lz4
		app-arch/xz-utils
		dev-libs/libunistring
		net-dns/libidn2
		net-libs/libssh2
		net-libs/libpsl
		net-libs/nghttp2
		net-libs/nghttp3
		net-dns/c-ares
		sys-apps/acl
		sys-fs/e2fsprogs
		virtual/zlib
		)
	dev-libs/libfmt
	dev-libs/spdlog
	net-misc/curl
	python? ( ${PYTHON_DEPS} )
"
RDEPEND="${DEPEND}"
BDEPEND="
	python? (
		${PYTHON_DEPS}
		${DISTUTILS_DEPS}
		$(python_gen_cond_dep 'dev-python/pybind11[${PYTHON_USEDEP}]')
		$(python_gen_cond_dep 'dev-python/scikit-build-core[${PYTHON_USEDEP}]')
	)
"

PATCHES=(
	"${FILESDIR}/mamba-sh.patch"
	"${FILESDIR}/${P}-fix-UnresolvedChannel.patch"
	"${FILESDIR}/${P}-fix-missing-functional.patch"
)

src_prepare() {
	cmake_src_prepare
	use python && {
		pushd libmambapy || die
		distutils-r1_src_prepare
	}
}

src_configure() {
	cat >"${T}"/zstdConfig.cmake <<-EOF || die
		add_library(zstd::libzstd_shared SHARED IMPORTED)
		set_target_properties(zstd::libzstd_shared PROPERTIES
			IMPORTED_LOCATION "${EPREFIX}/usr/$(get_libdir)/libzstd$(get_libname)")
	EOF
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON
		-DBUILD_MAMBA=$(usex mamba)
		-DBUILD_LIBMAMBA=ON
		-DBUILD_LIBMAMBAPY=$(usex python)
		-DBUILD_LIBMAMBA_TESTS=NO
		-DBUILD_MAMBA_PACKAGE=OFF
		-DBUILD_MICROMAMBA=OFF
		-DBUILD_SHARED=ON
		-DBUILD_STATIC=OFF
		-DBUILD_LIBMAMBA_SPDLOG=ON
		-Dzstd_DIR="${T}"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	if use python; then
		cmake --install "${BUILD_DIR}" --prefix "${T}"
		cd libmambapy || die
		export CMAKE_PREFIX_PATH="${T}"
		export SKBUILD_CONFIGURE_OPTIONS="\
		-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
		-DBUILD_LIBMAMBA=ON \
		-DBUILD_LIBMAMBAPY=ON \
		-DBUILD_MICROMAMBA=OFF \
		-DBUILD_MAMBA_PACKAGE=OFF"
		distutils-r1_src_compile
	fi
}

src_install() {
	cmake_src_install
	if use python; then
		cd libmambapy || die
		distutils-r1_src_install
	fi
	if use mamba; then
		insinto /usr/etc/profile.d
		doins "${BUILD_DIR}/micromamba/etc/profile.d/mamba.sh"
	fi
}
