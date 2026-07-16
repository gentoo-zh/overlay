# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..14} )
inherit distutils-r1

DESCRIPTION="A simple immutable dictionary for Python"
HOMEPAGE="https://github.com/Marco-Sulla/python-frozendict"
SRC_URI="https://github.com/Marco-Sulla/python-frozendict/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/python-${PN}-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	$(python_gen_cond_dep 'dev-python/setuptools-scm[${PYTHON_USEDEP}]')
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_prepare_all() {
	# upstream declares the license as a multi-line concatenated classifier;
	# current setuptools flags "License ::" classifiers as deprecated and the
	# resulting QA elog fails CI. Drop the whole parenthesized License :: block
	# (SLOT/LICENSE metadata already carries the licensing).
	sed -i '/^[[:space:]]*($/{:x;N;/),/!bx;/License ::/d}' setup.py || die
	distutils-r1_python_prepare_all
}
