# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1

DESCRIPTION="An efficient library to read from new and old conda packages"
HOMEPAGE="https://github.com/conda/conda-package-streaming"
SRC_URI="https://github.com/conda/conda-package-streaming/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="
	dev-python/requests[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/backports-zstd[${PYTHON_USEDEP}]
	' python3_{12..13})"

RDEPEND="${DEPEND}"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
