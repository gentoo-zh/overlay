# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{13..14} )

inherit desktop distutils-r1 git-r3 xdg

DESCRIPTION="Wayland lyrics overlay for MPRIS-compatible media players"
HOMEPAGE="https://github.com/locez/kotonoha"
EGIT_REPO_URI="https://github.com/locez/kotonoha.git"

LICENSE="ISC LGPL-2.1+ MIT"
SLOT="0"

DEPEND="
	dev-libs/wayland
	dev-qt/qtbase:6=[gui,wayland,widgets]
	kde-plasma/layer-shell-qt:6
"
RDEPEND="
	${DEPEND}
	dev-python/aiohttp[${PYTHON_USEDEP}]
	dev-python/dbus-fast[${PYTHON_USEDEP}]
	dev-python/pyqt6[gui,svg,widgets,${PYTHON_USEDEP}]
	dev-python/qasync[${PYTHON_USEDEP}]
	dev-qt/qtwayland:6
	dev-qt/qtsvg:6
"
BDEPEND="
	dev-util/wayland-scanner
	virtual/pkgconfig
"

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest

python_configure_all() {
	DISTUTILS_ARGS=(
		-DKOTONOHA_INSTALL_DIR=kotonoha
		-DKOTONOHA_INSTALL_LICENSE=OFF
	)
}

python_install_all() {
	distutils-r1_python_install_all
	dodoc LICENSE
	domenu packaging/kotonoha.desktop
	newicon src/kotonoha/assets/icon.png kotonoha.png
	doman packaging/kotonoha.1
	insinto /usr/share/metainfo
	doins packaging/dev.locez.kotonoha.metainfo.xml
}
