# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
COMMIT_ID="191575084a4e951802c32a4177dc704cf435883a"
inherit distutils-r1

DESCRIPTION="GUI for snapper, a tool for Linux filesystem snapshot management"
HOMEPAGE="https://github.com/ricardomv/snapper-gui"
SRC_URI="https://github.com/ricardomv/snapper-gui/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/snapper-gui-${COMMIT_ID}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	app-backup/snapper
	$(python_gen_cond_dep 'dev-python/dbus-python[${PYTHON_USEDEP}] dev-python/pygobject[${PYTHON_USEDEP}]')
	x11-libs/gtksourceview:3.0
"

PATCHES=(
	# pkg_resources was removed from setuptools
	"${FILESDIR}"/${P}-pkg_resources.patch
)

src_prepare() {
	sed -i 's/Utilities;/Utility;/' "${S}/snapper-gui.desktop"
	default
}
