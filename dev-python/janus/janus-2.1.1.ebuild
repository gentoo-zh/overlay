# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} pypy3 )
PYPI_VERIFY_REPO=https://github.com/aio-libs/janus

inherit distutils-r1 pypi

DESCRIPTION="Mixed sync-async queue to interoperate between asyncio tasks and classic threads"
HOMEPAGE="https://github.com/aio-libs/janus"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="~amd64 ~arm64"
EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest

EPYTEST_IGNORE=(
	# needs pytest-codspeed, which is not packaged
	tests/test_benchmarks.py
)

python_test() {
	epytest -o addopts=
}
