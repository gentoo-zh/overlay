# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="
	Self-contained library to deal with metadata in egg and runtime archives
"
HOMEPAGE="
	https://github.com/enthought/okonomiyaki
	https://pypi.org/project/okonomiyaki/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="test"
