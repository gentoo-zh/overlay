# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
inherit python-any-r1

DESCRIPTION="A collection of Linux Mint themes"
HOMEPAGE="https://github.com/linuxmint/mint-themes"
SRC_URI="https://github.com/linuxmint/mint-themes/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_any_dep '
		dev-python/libsass[${PYTHON_USEDEP}]
	')
"

python_check_deps() {
	python_has_version "dev-python/libsass[${PYTHON_USEDEP}]"
}

src_compile() {
	python_setup
	"${PYTHON}" generate-themes.py || die
}

src_install() {
	insinto /usr/share/themes
	doins -r usr/share/themes/.
}
