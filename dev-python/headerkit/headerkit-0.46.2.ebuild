# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
DISTUTILS_USE_PEP517=hatchling
PYPI_VERIFY_REPO="https://github.com/axiomantic/headerkit"
inherit distutils-r1 pypi

DESCRIPTION="C/C++ header analysis toolkit with pluggable backends and writers"
HOMEPAGE="
	https://github.com/axiomantic/headerkit
	https://pypi.org/project/headerkit/
"

LICENSE="MIT Apache-2.0-with-LLVM-exceptions"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
RESTRICT="test"
