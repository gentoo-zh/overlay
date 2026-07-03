# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="a powerful command-line tool"
HOMEPAGE="https://sr.ht/~cwt/ananta/"

RDEPEND="
	<dev-python/asyncssh-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/asyncssh-2.20.0[${PYTHON_USEDEP}]
	>=dev-python/urwid-2.1.2[${PYTHON_USEDEP}]
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
