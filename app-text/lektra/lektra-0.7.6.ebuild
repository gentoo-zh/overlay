# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

MUPDF_PV="1.27.2"
SYNCTEX_COMMIT="917617707955cde0c2fae127130d9d3129303cbc"

DESCRIPTION="High-performance PDF reader that prioritizes screen space and control"
HOMEPAGE="https://github.com/dheerajshenoy/lektra"
SRC_URI="
	https://github.com/dheerajshenoy/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://mupdf.com/downloads/archive/mupdf-${MUPDF_PV}-source.tar.gz
	synctex? (
		https://github.com/jlaurens/synctex/archive/${SYNCTEX_COMMIT}.tar.gz
			-> ${PN}-synctex-${SYNCTEX_COMMIT}.tar.gz
	)
"

# lektra is AGPL-3; the bundled synctex parser is MIT.
LICENSE="AGPL-3 synctex? ( MIT )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="synctex"

# mupdf and, with synctex, the synctex parser are git submodules absent
# from the release tarball; both are vendored via SRC_URI. mupdf is built
# by the project's ExternalProject step through its own Makefile.
DEPEND="
	dev-qt/qtbase:6[concurrent,gui,network,opengl,widgets]
	dev-qt/qtsvg:6
	virtual/zlib
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/cmake
	dev-qt/qttools:6[linguist]
"

src_prepare() {
	# The release tarball ships empty thirdparty/mupdf and thirdparty/synctex
	# submodule directories; populate them from the vendored sources.
	rmdir "${S}/thirdparty/mupdf" || die
	mv "${WORKDIR}/mupdf-${MUPDF_PV}-source" "${S}/thirdparty/mupdf" || die

	if use synctex; then
		rmdir "${S}/thirdparty/synctex" || die
		mv "${WORKDIR}/synctex-${SYNCTEX_COMMIT}" "${S}/thirdparty/synctex" || die
	fi

	# CMake 4 dropped compatibility with cmake_minimum_required() < 3.5.
	# mupdf's bundled thirdparty CMake projects (zlib, freetype, freeglut,
	# curl, ...) declare older minimums. They build through mupdf's Makefile,
	# not CMake, but cmake.eclass still scans the tree and, on finding them,
	# applies a policy workaround that trips the overlay elog gate as a QA
	# notice. Raise every bundled minimum so the scan finds none.
	find "${S}/thirdparty/mupdf" -name CMakeLists.txt -exec sed -i -E \
		-e 's/^(\s*cmake_minimum_required\s*\(\s*VERSION\s+)[0-9.]+/\13.15/I' {} + || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITH_SYNCTEX=$(usex synctex ON OFF)
		-DWITH_LUA=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Upstream installs docs to /usr/share/doc/lektra,
	# but Gentoo requires /usr/share/doc/${PF}.
	if [[ -d "${ED}/usr/share/doc/${PN}" && "${PN}" != "${PF}" ]]; then
		mv "${ED}/usr/share/doc/${PN}"/* "${ED}/usr/share/doc/${PF}/" || die
		rmdir "${ED}/usr/share/doc/${PN}" || die
	fi
}
