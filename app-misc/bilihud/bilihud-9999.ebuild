# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{13..14} )

inherit desktop distutils-r1 git-r3

DESCRIPTION="Bilibili danmaku overlay for fullscreen games"
HOMEPAGE="https://github.com/locez/bilihud"
EGIT_REPO_URI="https://github.com/locez/bilihud.git"
EGIT_SUBMODULES=( '*' )

LICENSE="MIT"
SLOT="0"

RDEPEND="
	app-arch/brotli[python,${PYTHON_USEDEP}]
	dev-python/aiohttp[${PYTHON_USEDEP}]
	dev-python/browser-cookie3[${PYTHON_USEDEP}]
	dev-python/keyring[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/pure-protobuf[${PYTHON_USEDEP}]
	dev-python/pyqt6[${PYTHON_USEDEP}]
	dev-python/qasync[${PYTHON_USEDEP}]
	dev-python/qrcode[${PYTHON_USEDEP}]
	dev-qt/qtbase:6
	dev-qt/qtwayland:6
	kde-plasma/layer-shell-qt
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_prepare_all() {
	sed -i \
		-e '/hatch-build-scripts/d' \
		-e '/\[tool.hatch.build.hooks.build-scripts\]/,/artifacts =/d' \
		pyproject.toml || die

	distutils-r1_python_prepare_all
}

src_compile() {
	./src/bilihud/build_bridge.sh || die
	distutils-r1_src_compile
}

python_install_all() {
	distutils-r1_python_install_all
	domenu bilihud.desktop
	newicon src/bilihud/assets/icon.png bilihud.png
}
