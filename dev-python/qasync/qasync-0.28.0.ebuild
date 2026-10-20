# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Implementation of the asyncio (PEP 3156) event-loop with Qt"
HOMEPAGE="https://github.com/CabbageDevelopment/qasync"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	|| (
		dev-python/pyqt6[${PYTHON_USEDEP}]
		dev-python/pyside[${PYTHON_USEDEP}]
	)

"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"

src_prepare() {
	sed -i \
		-e 's/build-backend = "uv_build"/build-backend = "hatchling.build"/' \
		-e 's/requires = \["uv_build.*"\]/requires = ["hatchling"]/' \
		pyproject.toml || die

	distutils-r1_src_prepare
}
