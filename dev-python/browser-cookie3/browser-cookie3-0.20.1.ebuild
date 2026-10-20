# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )

inherit distutils-r1 pypi

DESCRIPTION="Loads cookies from your browser into a cookiejar object"
HOMEPAGE="https://github.com/borisbabic/browser_cookie3"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# Tests require local browser files which are not available in sandbox.
RESTRICT="test"

RDEPEND="
	dev-python/jeepney[${PYTHON_USEDEP}]
	dev-python/lz4[${PYTHON_USEDEP}]
	dev-python/pycryptodome[${PYTHON_USEDEP}]
"

src_prepare() {
	sed -i 's/Cryptodome/Crypto/g' browser_cookie3/__init__.py || die
	sed -i 's/pycryptodomex/pycryptodome/g' setup.py || die
	distutils-r1_src_prepare
}
