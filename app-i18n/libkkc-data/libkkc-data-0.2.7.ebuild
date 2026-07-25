# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-any-r1

DESCRIPTION="Language model data for the libkkc Japanese input method"
HOMEPAGE="https://github.com/ueno/libkkc"
SRC_URI="https://github.com/ueno/${PN%-*}/releases/download/v0.3.5/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

# sortlm.py/genfilter.py build the marisa tries via the marisa python binding.
BDEPEND="$(python_gen_any_dep '
	dev-libs/marisa[python,${PYTHON_USEDEP}]
')"

PATCHES=(
	"${FILESDIR}"/${P}-python3.patch
)

python_check_deps() {
	python_has_version "dev-libs/marisa[python,${PYTHON_USEDEP}]"
}
