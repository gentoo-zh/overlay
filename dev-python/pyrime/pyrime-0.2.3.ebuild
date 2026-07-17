# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=meson-python
PYTHON_COMPAT=( python3_{11..14} )
inherit distutils-r1 pypi

DESCRIPTION="rime for python"
HOMEPAGE="
	https://github.com/rimeinn/pyrime
	https://pypi.org/project/pyrime
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="prompt-toolkit"

DEPEND="
	app-i18n/librime
"
RDEPEND="
	${DEPEND}
	dev-python/platformdirs[${PYTHON_USEDEP}]
	dev-python/wcwidth[${PYTHON_USEDEP}]
	prompt-toolkit? (
		dev-python/prompt-toolkit[${PYTHON_USEDEP}]
	)
"
BDEPEND="
	dev-python/autopxd2[${PYTHON_USEDEP}]
	dev-python/cython[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( )

distutils_enable_tests pytest
