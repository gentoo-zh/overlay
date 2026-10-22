# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1

DESCRIPTION="The libmamba based solver for conda"
HOMEPAGE="https://github.com/conda/conda-libmamba-solver"
SRC_URI="https://github.com/conda/conda-libmamba-solver/archive/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/conda-libmamba-solver-${PV}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	$(python_gen_cond_dep 'dev-python/setuptools-scm[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/hatch-vcs[${PYTHON_USEDEP}]')
"

RDEPEND="
	$(python_gen_cond_dep 'dev-python/boltons[${PYTHON_USEDEP}]')
	sys-libs/libsolv:=[conda,${PYTHON_SINGLE_USEDEP}]
	dev-util/mamba:=[python,${PYTHON_SINGLE_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
