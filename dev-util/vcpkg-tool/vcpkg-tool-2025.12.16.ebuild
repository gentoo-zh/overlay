# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Library manager for C/C++ (tool only)."
HOMEPAGE="https://github.com/microsoft/vcpkg-tool https://vcpkg.io/en/index.html"
format-date() {
	local input="$1"
	IFS='.' read -r year month day <<< "$input"
	printf '%04d-%02d-%02d' "$year" "$month" "$day"
}
MY_PV="$(format-date "${PV}")"
SRC_URI="https://github.com/microsoft/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${MY_PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="dev-libs/libfmt:0/11.2.0"
RDEPEND="${DEPEND}"
BDEPEND="dev-util/cmakerc"

src_prepare() {
	sed -i \
		-e 's/cmake_minimum_required(VERSION 3\.7\.2)/cmake_minimum_required(VERSION 3.10)/' \
		azure-pipelines/e2e-ports/broken-symlink/src/CMakeLists.txt \
		azure-pipelines/e2e-ports/vcpkg-cmake-config-many-targets/src/CMakeLists.txt \
		azure-pipelines/e2e-ports/vcpkg-hello-world-1/src/CMakeLists.txt \
		azure-pipelines/e2e-ports/vcpkg-hello-world-2/src/CMakeLists.txt \
		|| die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		"-DBUILD_TESTING=$(usex test)"
		"-DVCPKG_ARTIFACTS_SHA=775c0b327487c04180e43f61813caf097da9a1f223030a486425e2ffbea255c48ba22e4add10401c8aa6e1e9bd53f182d694f363942ce99d7dd5dfafe9cc07fb"
		"-DVCPKG_STANDALONE_BUNDLE_SHA=$(grep -E 'VCPKG_STANDALONE_BUNDLE_SHA"' CMakePresets.json | cut '-d"' -f4)"
		-DCMAKE_POLICY_VERSION_MINIMUM=3.5
		-DBUILD_SHARED_LIBS=OFF
		-DVCPKG_BASE_VERSION=2024-01-11
		-DVCPKG_BUILD_TLS12_DOWNLOADER=OFF
		-DVCPKG_DEPENDENCY_CMAKERC=ON
		-DVCPKG_DEPENDENCY_EXTERNAL_FMT=ON
		-DVCPKG_DEVELOPMENT_WARNINGS=OFF
		-DVCPKG_EMBED_GIT_SHA=OFF
		-DVCPKG_OFFICIAL_BUILD=ON
		-DVCPKG_WARNINGS_AS_ERRORS=OFF
		-DCMAKE_DISABLE_PRECOMPILE_HEADERS=OFF
	)
	cmake_src_configure
}

pkg_postinst() {
	einfo
	einfo 'To use vcpkg you need to have a copy of https://github.com/microsoft/vcpkg'
	einfo 'or another root somewhere and point to it with the VCPKG_ROOT environment'
	einfo 'variable or by passing --vcpkg-root=<path>.'
	einfo
}
