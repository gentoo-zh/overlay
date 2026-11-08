# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Reqable = Fiddler + Charles + Postman, 让API调试更快 🚀 更简单 👌"
HOMEPAGE="https://reqable.com/en-US/"
SRC_URI="https://github.com/reqable/reqable-app/releases/download/${PV}/reqable-app-linux-x86_64.deb -> ${P}.deb"

S="${WORKDIR}"
LICENSE="reqable_license"

SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-arch/lz4
	dev-libs/glib:2
	dev-libs/libdbusmenu[gtk3]
	dev-libs/nspr
	dev-libs/nss
	media-libs/fontconfig
	media-libs/harfbuzz
	media-libs/libepoxy
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
"

RESTRICT="strip mirror bindist"

QA_PREBUILT="usr/share/reqable/*"

src_install() {
	insinto /usr/share/reqable
	doins -r "${S}"/usr/share/reqable/*
	fperms 755 /usr/share/reqable/reqable
	fperms 755 /usr/share/reqable/mcp-server
	domenu "${S}"/usr/share/applications/reqable.desktop
	doicon -s 1024 "${S}"/usr/share/pixmaps/reqable.png
}
