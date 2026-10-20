# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} pypy3 )

inherit distutils-r1 pypi

DESCRIPTION="A module and utility to work with the simple filesystem on the BBC micro:bit"
HOMEPAGE="
	https://github.com/blackteahamburger/microfs
	https://pypi.org/project/microfs2
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/pyserial-3.0.1[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
