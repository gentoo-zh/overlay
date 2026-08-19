# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg desktop unpacker

DESCRIPTION="The official unity tool for manager Unity Engines and projects"
HOMEPAGE="https://docs.unity.com/en-us/hub"
SRC_URI="https://hub.unity3d.com/linux/repos/deb/pool/main/u/unity/unityhub_amd64/unityhub_${PV}_amd64.deb -> ${PN}-amd64-${PV}.deb"
S=${WORKDIR}

LICENSE="unity-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+appindicator legacy"
RESTRICT="bindist mirror strip"

DEPEND="
	appindicator? (
		dev-libs/libdbusmenu
		legacy? (
			dev-libs/libayatana-appindicator
			x11-misc/appmenu-gtk-module[gtk2]
		)
	)
	app-arch/cpio
	dev-libs/nss
	dev-util/lttng-ust:0/2.12
	x11-libs/gtk+
	app-crypt/libsecret
	dev-libs/openssl-compat
	media-libs/alsa-lib
"
RDEPEND="${DEPEND}"

src_unpack(){
	unpack_deb ${PN}-amd64-${PV}.deb
}
src_install(){
	insinto /opt
	doins -r usr/lib/unityhub
	dosym -r /opt/unityhub/unityhub /usr/bin/unityhub
	doicon -s 1024 usr/share/pixmaps/${PN}.png
	domenu usr/share/applications/${PN}.desktop
	fperms 0755 -R /opt/unityhub
}
