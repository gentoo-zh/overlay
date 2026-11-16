# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )  # doesn't build with pypy3
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYPI_VERIFY_REPO="https://github.com/MagicStack/asyncpg"
inherit distutils-r1 pypi

DESCRIPTION="An asyncio PostgreSQL driver"
HOMEPAGE="
	https://pypi.org/project/asyncpg/
	https://github.com/MagicStack/asyncpg
"

LICENSE="Apache-2.0 PSF-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="kerberos"

RDEPEND="
	kerberos? ( dev-python/gssapi[${PYTHON_USEDEP}] )
"
BDEPEND="
	>=dev-python/cython-3.2.1[${PYTHON_USEDEP}]
	<dev-python/cython-4[${PYTHON_USEDEP}]
	test? (
		dev-db/postgresql[kerberos?,server(+),ssl]
		dev-python/distro[${PYTHON_USEDEP}]
		dev-python/uvloop[${PYTHON_USEDEP}]
		kerberos? (
			app-crypt/mit-krb5
			dev-python/k5test[${PYTHON_USEDEP}]
		)
	)
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.32.0-cflags.patch
)

EPYTEST_PLUGINS=( )
EPYTEST_IGNORE=(
	# checks versions from env variables
	"${S}"/tests/test__environment.py
	# runs flake8 (???)
	"${S}"/tests/test__sourcecode.py
)

distutils_enable_tests pytest

distutils_enable_sphinx docs \
	dev-python/sphinx-rtd-theme

python_prepare_all() {
	# bug #926720
	cat <<-EOF >> setup.cfg || die
		[build_ext]
		debug=False
		cython_always=True
		cython_annotate=False
		cython_directives=
	EOF

	# remove pre-generated Cython sources
	rm asyncpg/{pgproto/pgproto,protocol/protocol}.c || die

	distutils-r1_python_prepare_all
}

python_configure_all() {
	use kerberos || \
		EPYTEST_DESELECT+=( tests/test_connect.py::TestGssAuthentication )
}

python_test() {
	cd "${T}" || die
	for opt in "" "1"; do
		einfo "  testing with USE_UVLOOP='${opt}'"
		USE_UVLOOP="${opt}" epytest "${S}"/tests
	done
}
