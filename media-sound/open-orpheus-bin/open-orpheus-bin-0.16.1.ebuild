# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="An open-source implementation of Netease Cloud Music's Orpheus browser host"
HOMEPAGE="https://github.com/YUCLing/open-orpheus"
SRC_URI="
	amd64? (
		https://github.com/YUCLing/open-orpheus/releases/download/v${PV}/open-orpheus_${PV}_amd64.deb
			-> open-orpheus-${PV}-amd64.deb
	)
	arm64? (
		https://github.com/YUCLing/open-orpheus/releases/download/v${PV}/open-orpheus_${PV}_arm64.deb
			-> open-orpheus-${PV}-arm64.deb
	)
"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/nss
	media-libs/alsa-lib
	net-print/cups
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libXi
	x11-libs/libXdamage
	x11-libs/libXcomposite
	x11-libs/libxkbcommon
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/open-orpheus/*"

src_install() {
	insinto /opt/open-orpheus
	doins -r usr/lib/open-orpheus/*
	fperms +x /opt/open-orpheus/{open-orpheus,chrome-sandbox,chrome_crashpad_handler}
	fperms u+s /opt/open-orpheus/chrome-sandbox
	dosym ../../opt/open-orpheus/open-orpheus /usr/bin/open-orpheus
	domenu usr/share/applications/open-orpheus.desktop
	doicon usr/share/pixmaps/open-orpheus.png
}
