# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg unpacker

DESCRIPTION="A simple and elegant markdown editor, available for Linux, macOS and Windows"
HOMEPAGE="https://github.com/marktext/marktext"
SRC_URI="https://github.com/marktext/marktext/releases/download/v${PV}/${PN%-bin}-linux-${PV}.deb -> ${P}.deb"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib
	app-crypt/libsecret
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus[X]
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbfile
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
"

QA_PREBUILT="
	opt/MarkText/chrome_crashpad_handler
	opt/MarkText/libEGL.so
	opt/MarkText/libffmpeg.so
	opt/MarkText/libGLESv2.so
	opt/MarkText/libvk_swiftshader.so
	opt/MarkText/libvulkan.so.1
	opt/MarkText/marktext
	opt/MarkText/resources/app.asar.unpacked/node_modules/*
"

src_prepare(){
	default
	sed -i 's|^MimeType=.*|MimeType=text/markdown;|' usr/share/applications/${PN%-bin}.desktop || die
	sed -i 's|^Categories=.*|Categories=Utility;TextEditor;|' usr/share/applications/${PN%-bin}.desktop || die
	unpack usr/share/doc/${PN%-bin}/changelog.gz
}

src_install(){
	insinto /opt
	doins -r opt/MarkText

	insinto /usr/share
	doins -r usr/share/icons

	dodoc changelog
	domenu usr/share/applications/${PN%-bin}.desktop

	local f
	for f in ${QA_PREBUILT}; do
		fperms +x "/${f}"
	done

	dosym ../../opt/MarkText/${PN%-bin} /usr/bin/${PN%-bin}
}
