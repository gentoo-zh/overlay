# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

PATCHES=(
	"${FILESDIR}/${P}-remove-deprecated-license-classifier.patch"
)

DESCRIPTION="
Award-winnning package manager and build abstraction tool for HDL code
"
HOMEPAGE="
	https://github.com/olofk/fusesoc/
	https://pypi.org/project/fusesoc/
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/edalize-0.4.1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.13.3[${PYTHON_USEDEP}]
	>=dev-python/pyparsing-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0[${PYTHON_USEDEP}]
	>=dev-python/simplesat-0.9.1[${PYTHON_USEDEP}]
	dev-python/fastjsonschema[${PYTHON_USEDEP}]
	dev-python/argcomplete[${PYTHON_USEDEP}]
"

# prohibit network environment
RESTRICT="test"
