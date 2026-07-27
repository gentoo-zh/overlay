# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2-utils

DESCRIPTION="context-menu entry for opening other terminal in nautilus"
HOMEPAGE="https://github.com/Stunkymonkey/nautilus-open-any-terminal"
SRC_URI="https://github.com/Stunkymonkey/nautilus-open-any-terminal/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/nautilus-python
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/make
	sys-devel/gettext
"

pkg_postinst() {
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_schemas_update
}
