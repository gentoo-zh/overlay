# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14})

inherit distutils-r1

DESCRIPTION="youtube music support for feeluown"
HOMEPAGE="https://github.com/feeluown/feeluown-ytmusic"

SRC_URI="https://github.com/feeluown/feeluown-ytmusic/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/feeluown-ytmusic-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
# tests import feeluown (a PDEPEND) and reach the live YouTube Music API
RESTRICT="test"

RDEPEND="
	dev-python/ytmusicapi[${PYTHON_USEDEP}]
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
	dev-python/cachetools[${PYTHON_USEDEP}]
"

PDEPEND="
	media-sound/feeluown
	net-misc/yt-dlp
"
