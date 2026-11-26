# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{13..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python port of the fzy fuzzy string matching algorithm"
HOMEPAGE="
	https://github.com/kazhala/pfzy
	https://pypi.org/project/pfzy/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest
