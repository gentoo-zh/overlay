# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} pypy3 )
PYPI_VERIFY_REPO=https://github.com/aio-libs/janus

inherit distutils-r1 pypi

DESCRIPTION="Mixed sync-async queue to interoperate between asyncio tasks and classic threads"
HOMEPAGE="https://github.com/aio-libs/janus"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
	)
"

python_test() {
	py.test -v || die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all
}
