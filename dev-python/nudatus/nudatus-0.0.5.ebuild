# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1

DESCRIPTION="CircuitPython board identification and information"
HOMEPAGE="
	https://github.com/ZanderBrown/nudatus
	https://pypi.org/project/nudatus
"
SRC_URI="https://github.com/ZanderBrown/nudatus/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

PATCHES=(
	"${FILESDIR}/${P}-python3.12-fix.patch"
)

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
