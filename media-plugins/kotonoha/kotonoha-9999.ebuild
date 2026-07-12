# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{13..14} )

inherit desktop distutils-r1 git-r3

DESCRIPTION="Wayland lyrics overlay for MPRIS-compatible media players"
HOMEPAGE="https://github.com/locez/kotonoha"
EGIT_REPO_URI="https://github.com/locez/kotonoha.git"
EGIT_SUBMODULES=( '*' )

LICENSE="MIT"
SLOT="0"

RDEPEND="
	dev-python/aiohttp[${PYTHON_USEDEP}]
	dev-python/dbus-fast[${PYTHON_USEDEP}]
	dev-python/pyqt6[svg,${PYTHON_USEDEP}]
	dev-python/qasync[${PYTHON_USEDEP}]
	dev-qt/qtbase:6
	dev-qt/qtwayland:6
	kde-plasma/layer-shell-qt
"

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest

python_prepare_all() {
	sed -i \
		-e '/hatch-build-scripts/d' \
		-e '/\[tool.hatch.build.hooks.build-scripts\]/,/artifacts =/d' \
		pyproject.toml || die

	distutils-r1_python_prepare_all
}

src_compile() {
	./src/kotonoha/build_bridge.sh || die
	distutils-r1_src_compile
}

python_install_all() {
	distutils-r1_python_install_all
	domenu packaging/kotonoha.desktop
	newicon src/kotonoha/assets/icon.png kotonoha.png
}
