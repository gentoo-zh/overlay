# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

PATCHES=(
	"${FILESDIR}/${P}-fix-setuptools-warnings.patch"
)

DESCRIPTION="
	Library for interfacing EDA tools
"
HOMEPAGE="
	https://github.com/olofk/edalize/
	https://pypi.org/project/edalize/
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/jinja2-3[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest
