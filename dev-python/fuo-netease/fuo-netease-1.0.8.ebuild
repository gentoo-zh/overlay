# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} pypy)

inherit distutils-r1 pypi

DESCRIPTION="netease cloud music support for feeluown"
HOMEPAGE="https://github.com/feeluown/feeluown-netease"

LICENSE="GPL-3"
SLOT="1"
KEYWORDS="~amd64"
# tests import feeluown (a PDEPEND) and reach the live NetEase Cloud Music API
RESTRICT="test"

RDEPEND="
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/pycryptodome[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/marshmallow[${PYTHON_USEDEP}]
	media-libs/mutagen[${PYTHON_USEDEP}]
"

PDEPEND="
	media-sound/feeluown
"
