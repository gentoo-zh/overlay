# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} pypy3 )

inherit distutils-r1 pypi

DESCRIPTION="A REPL client for MicroPython running on the BBC micro:bit"
HOMEPAGE="
	https://github.com/ntoll/microrepl
	https://pypi.org/project/microrepl
"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/pyserial-3.0.1[${PYTHON_USEDEP}]
"
