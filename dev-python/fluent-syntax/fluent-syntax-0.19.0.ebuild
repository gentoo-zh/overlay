# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )
PYPI_NO_NORMALIZE=1
PYPI_PN="fluent.syntax"

inherit distutils-r1 pypi

DESCRIPTION="Parser and serializer for Fluent localization files"
HOMEPAGE="https://github.com/projectfluent/python-fluent"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="dev-python/typing-extensions[${PYTHON_USEDEP}]"

src_prepare() {
	# Silence the setuptools deprecation warnings (License classifier,
	# test_suite, bdist_wheel.universal) that trip the QA setuptools gate.
	sed -i -e "/License :: OSI Approved/d" -e "/test_suite=/d" setup.py || die
	sed -i -e "/^\[bdist_wheel\]/d" -e "/^universal = 1/d" setup.cfg || die
	distutils-r1_src_prepare
}
