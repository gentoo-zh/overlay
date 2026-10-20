# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Library manager for C/C++ (tool only)"
HOMEPAGE="https://github.com/microsoft/vcpkg-tool https://vcpkg.io/en/index.html"
MY_PV="${PV//./-}"
SRC_URI="https://github.com/microsoft/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${MY_PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="dev-libs/libfmt:=
	net-misc/curl"
RDEPEND="${DEPEND}
	app-arch/zip"
BDEPEND="dev-util/cmakerc"

src_prepare() {
	# Bump the ancient cmake_minimum_required in the e2e-port test fixtures so the
	# cmake eclass < 3.10 QA scan stays quiet. Match them all rather than a fixed
	# list, since upstream keeps adding such ports.
	find azure-pipelines/e2e-ports -name CMakeLists.txt \
		-exec sed -i -e 's/cmake_minimum_required(VERSION 3\.7\.2)/cmake_minimum_required(VERSION 3.10)/' {} + || die

	cmake_src_prepare
}

src_configure() {
	local preset value
	local mycmakeargs=(
		"-DBUILD_TESTING=$(usex test)"
		-DCMAKE_POLICY_VERSION_MINIMUM=3.5
		-DBUILD_SHARED_LIBS=OFF
		-DVCPKG_BUILD_TLS12_DOWNLOADER=OFF
		-DVCPKG_DEPENDENCY_CMAKERC=ON
		-DVCPKG_DEPENDENCY_EXTERNAL_FMT=ON
		-DVCPKG_LIBCURL_DLSYM=OFF
		-DVCPKG_DEVELOPMENT_WARNINGS=OFF
		-DVCPKG_EMBED_GIT_SHA=OFF
		-DVCPKG_OFFICIAL_BUILD=ON
		-DVCPKG_WARNINGS_AS_ERRORS=OFF
		-DCMAKE_DISABLE_PRECOMPILE_HEADERS=OFF
	)

	for preset in VCPKG_ARTIFACTS_SHA VCPKG_BASE_VERSION VCPKG_STANDALONE_BUNDLE_SHA; do
		value=$(awk -F '"' -v key="${preset}" '$2 == key { print $4; exit }' \
			CMakePresets.json) || die
		[[ -n ${value} ]] || die "missing ${preset} in CMakePresets.json"
		mycmakeargs+=( "-D${preset}=${value}" )
	done

	cmake_src_configure
}

pkg_postinst() {
	einfo
	einfo 'To use vcpkg you need to have a copy of https://github.com/microsoft/vcpkg'
	einfo 'or another root somewhere and point to it with the VCPKG_ROOT environment'
	einfo 'variable or by passing --vcpkg-root=<path>.'
	einfo
}
