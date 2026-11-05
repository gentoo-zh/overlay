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

BDEPEND="dev-util/patchelf"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/ayatana-ido
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/libayatana-indicator:3
	dev-libs/libdbusmenu
	media-libs/harfbuzz
	media-libs/libepoxy
	sys-auth/polkit
	x11-apps/xmessage
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXmu
	x11-libs/pango
	virtual/jdk
	amd64? ( media-libs/fontconfig )
	arm64? ( virtual/zlib )
"

QA_PRESTRIPPED="
	/opt/FlClash/FlClashCore
	/opt/FlClash/lib/libapp.so
	/opt/FlClash/lib/librust_api.so
	/opt/FlClash/lib/libflutter_linux_gtk.so
"

QA_PREBUILT="
	opt/FlClash/FlClash
	opt/FlClash/FlClashHelperService
	opt/FlClash/lib/*
"

src_prepare() {
	default

	# upstream builds libdartjni.so against a Debian JVM path
	patchelf --set-rpath "${EPREFIX}/etc/java-config-2/current-system-vm/lib/server" \
		opt/FlClash/lib/libdartjni.so || die
}

src_install() {
	domenu usr/share/applications/FlClash.desktop
	doicon -s 128 usr/share/icons/hicolor/128x128/apps/FlClash.png
	doicon -s 256 usr/share/icons/hicolor/256x256/apps/FlClash.png

	insinto /opt/FlClash
	doins opt/FlClash/FlClashCore
	doins opt/FlClash/FlClash
	doins opt/FlClash/FlClashHelperService
	doins opt/FlClash/manifest.json
	doins -r opt/FlClash/lib
	doins -r opt/FlClash/data

	fperms +x /opt/FlClash/FlClashCore
	fperms +x /opt/FlClash/FlClash
	fperms +x /opt/FlClash/FlClashHelperService

	# the helper verifies FlClashCore against the sha256 in manifest.json
	dostrip -x /opt/FlClash/FlClashCore

	dosym ../../opt/FlClash/FlClash /usr/bin/FlClash
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "FlClashHelperService installs a root systemd unit on first use."
	elog "Run 'systemctl disable --now flclash-helper.service' before unmerging."
}
