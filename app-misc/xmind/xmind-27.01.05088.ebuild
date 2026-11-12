# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DATE_VER="202611110807"
DESCRIPTION="Brainstorming and Mind Mapping Software"
HOMEPAGE="https://xmind.com"
SRC_URI="https://dl3.xmind.app/Xmind-for-Linux-amd64bit-${PV}-${DATE_VER}.deb"

S=${WORKDIR}
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="opt/Xmind/*"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/pango
"

src_install() {
	insinto /opt
	doins -r opt/*
	fperms +x /opt/Xmind/{xmind,chrome_crashpad_handler,chrome-sandbox,libEGL.so,libffmpeg.so,libGLESv2.so,libvk_swiftshader.so,libvulkan.so.1}
	dosym -r "/opt/Xmind/xmind" "/usr/bin/xmind"
	for size in 16 32 48 64 128 256 512 1024; do
		doicon -s $size usr/share/icons/hicolor/"$size"x"$size"/apps/xmind.png
	done
	insinto /usr/share/mime/packages
	doins usr/share/mime/packages/xmind.xml
	sed -i \
		-e '/^\[Desktop Action StartupNotify\]/,$d' \
		-e '/^Terminal=/a StartupNotify=true' \
		usr/share/applications/xmind.desktop || die
	domenu usr/share/applications/xmind.desktop
	gzip -d usr/share/doc/xmind-vana/changelog.gz || die
	dodoc usr/share/doc/xmind-vana/changelog
}
