# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry-core
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 optfeature

DESCRIPTION="A pythonic generic language server"
HOMEPAGE="
	https://github.com/openlawlibrary/pygls
	https://pypi.org/project/pygls
"
SRC_URI="https://github.com/openlawlibrary/pygls/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/cattrs[${PYTHON_USEDEP}]
	dev-python/lsprotocol[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/websockets[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest

pkg_postinst() {
	optfeature "websockets support" dev-python/websockets
}
