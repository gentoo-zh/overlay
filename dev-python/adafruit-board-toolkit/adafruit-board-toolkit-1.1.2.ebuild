# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="CircuitPython board identification and information"
HOMEPAGE="
	https://github.com/adafruit/Adafruit_Board_Toolkit/
	https://pypi.org/project/adafruit-board-toolkit/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/pyserial-3.5[${PYTHON_USEDEP}]
"
