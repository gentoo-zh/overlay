# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qmake-utils desktop xdg

DESCRIPTION="A Linux Task Manager alternative built with Qt6"
HOMEPAGE="https://github.com/benapetr/TuxManager"
SRC_URI="https://github.com/benapetr/TuxManager/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/TuxManager-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	virtual/opengl
	dev-qt/qtbase:6[gui,widgets]
"
DEPEND="${RDEPEND}"

src_configure() {
	eqmake6 src/TuxManager.pro
}

src_install() {
	dobin tux-manager
	domenu packaging/data/io.github.benapetr.TuxManager.desktop
	doicon --size scalable src/tux_manager_icon.svg
}
