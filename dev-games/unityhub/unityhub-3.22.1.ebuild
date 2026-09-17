# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature unpacker xdg

DESCRIPTION="The official unity tool for manager Unity Engines and projects"
HOMEPAGE="https://docs.unity.com/en-us/hub"
SRC_URI="https://hub.unity3d.com/linux/repos/deb/pool/main/u/unity/unityhub_amd64/UnityHubSetup-${PV}-amd64.deb -> ${PN}-amd64-${PV}.deb"
S=${WORKDIR}

LICENSE="unity-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+appindicator libnotify"
RESTRICT="bindist mirror strip"

RDEPEND="
	appindicator? (
		dev-libs/libdbusmenu
	)
	libnotify? (
		x11-libs/libnotify
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-arch/cpio
	app-arch/unzip
	app-arch/zip
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	|| (
		dev-util/lttng-ust-compat:0/2.12
		dev-util/lttng-ust:0/2.12
	)
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	virtual/zlib
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
"

src_unpack(){
	unpack_deb ${PN}-amd64-${PV}.deb
}
src_install(){
	dodir /opt
	cp -a usr/lib/unityhub "${ED}/opt/" || die
	dosym -r /opt/unityhub/unityhub /usr/bin/unityhub
	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor
	domenu usr/share/applications/${PN}.desktop
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature_header "Older Unity Editor releases installed through the Hub may need:"
	optfeature "Editors before Unity's libxml2 fix (6000.0.76f1, 6000.3.13f1, 6000.4.1f1)" \
		dev-libs/libxml2-compat:2
}
