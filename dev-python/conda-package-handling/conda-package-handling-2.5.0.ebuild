# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1

DESCRIPTION="Create and extract conda packages of various formats"
HOMEPAGE="https://github.com/conda/conda-package-handling"
SRC_URI="https://github.com/conda/conda-package-handling/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="
	>=dev-python/conda-package-streaming-0.12.0[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/zstandard[${PYTHON_USEDEP}]"

RDEPEND="${DEPEND}"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
