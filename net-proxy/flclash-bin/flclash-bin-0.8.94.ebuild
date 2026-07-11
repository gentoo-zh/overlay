# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="A multi-platform proxy client based on ClashMeta"
HOMEPAGE="https://github.com/chen08209/FlClash"
SRC_URI="
	amd64? ( https://github.com/chen08209/FlClash/releases/download/v${PV}/FlClash-${PV}-linux-amd64.deb )
	arm64? ( https://github.com/chen08209/FlClash/releases/download/v${PV}/FlClash-${PV}-linux-arm64.deb )
"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	dev-libs/libayatana-appindicator
	dev-libs/keybinder
	x11-apps/xmessage
	x11-libs/libX11
	x11-libs/libXmu
	virtual/jdk
"

QA_PRESTRIPPED="
	/opt/FlClash/FlClashCore
	/opt/FlClash/lib/libapp.so
	/opt/FlClash/lib/librust_api.so
"

src_install() {
	sed -i '/^Version=/d' usr/share/applications/FlClash.desktop
	domenu usr/share/applications/FlClash.desktop
	doicon -s 128 usr/share/icons/hicolor/128x128/apps/FlClash.png
	doicon -s 256 usr/share/icons/hicolor/256x256/apps/FlClash.png

	insinto /opt/FlClash
	doins usr/share/FlClash/FlClashCore
	doins usr/share/FlClash/FlClash
	doins -r usr/share/FlClash/lib
	doins -r usr/share/FlClash/data

	fperms +x /opt/FlClash/FlClashCore
	fperms +x /opt/FlClash/FlClash

	dosym ../../opt/FlClash/FlClash /usr/bin/FlClash
}
