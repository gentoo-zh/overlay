# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Prototype for SAT-based dependency handling"
HOMEPAGE="
	https://github.com/enthought/sat-solver
	https://pypi.org/project/simplesat/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/attrs-17.4.0
	>=dev-python/okonomiyaki-0.16.6
	>=dev-python/six-1.10.0
	dev-python/mock
"

distutils_enable_tests pytest
