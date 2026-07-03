# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_MAKEFILE_GENERATOR=ninja
inherit xdg cmake

DESCRIPTION="A protocol plugin for Remmina to launch a Rustdesk connection."
HOMEPAGE="https://www.muflone.com/remmina-plugin-rustdesk/"
_BUILDERVER="1.4.27.0"
SRC_URI="
	https://github.com/muflone/remmina-plugin-builder/archive/${_BUILDERVER}.tar.gz \
		-> remmina-plugin-builder-${_BUILDERVER}.tar.gz
	https://github.com/muflone/remmina-plugin-rustdesk/archive/${PV}.tar.gz -> ${P}.tar.gz
"
S="${WORKDIR}/build"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	net-misc/rustdesk
	net-misc/remmina
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"

src_unpack() {
	default_src_unpack
	cp -r "remmina-plugin-builder-${_BUILDERVER}" build || die
	cp -r "${P}"/* "build/remmina-plugin-to-build" || die
}
