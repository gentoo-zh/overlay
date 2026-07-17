# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="MaixVision - AIoT development platform"
HOMEPAGE="https://sipeed.com/maixvision"
SRC_URI="https://cdn.sipeed.com/maixvision/${PV}/maixvision_${PV}_amd64.deb"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core
	app-crypt/libsecret
	dev-libs/nss
	media-libs/alsa-lib
	sys-apps/util-linux
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-misc/xdg-utils
"

src_install() {
	rm -r opt/MaixVision/resources/app.asar.unpacked/node_modules/@img/sharp-libvips-linuxmusl-x64 || die
	rm -r opt/MaixVision/resources/app.asar.unpacked/node_modules/@img/sharp-linuxmusl-x64 || die

	insinto /opt
	doins -r opt/MaixVision/

	fperms 755 /opt/MaixVision/maixvision
	fperms 755 /opt/MaixVision/resources/app.asar.unpacked/node_modules/node/bin/node

	domenu usr/share/applications/maixvision.desktop
	doicon -s 512 usr/share/icons/hicolor/512x512/apps/maixvision.png
	dosym ../../opt/MaixVision/maixvision /usr/bin/maixvision
}
