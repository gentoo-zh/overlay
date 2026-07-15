# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PN="${PN%-bin}"
DESCRIPTION="All-in-one manager for Claude Code, Codex, Gemini CLI, OpenCode, and OpenClaw"
HOMEPAGE="https://github.com/farion1231/cc-switch"
SRC_URI="amd64? (
	https://github.com/farion1231/cc-switch/releases/download/v${PV}/CC-Switch-v${PV}-Linux-x86_64.deb
		-> ${P}-amd64.deb
)"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+X wayland"

RESTRICT="strip"

RDEPEND="
	!app-misc/cc-switch
	app-arch/xz-utils
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/openssl:0/3
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1[X?,wayland?]
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	dobin usr/bin/${MY_PN}

	domenu "usr/share/applications/CC Switch.desktop"

	for size in 32 128; do
		doicon -s ${size} "usr/share/icons/hicolor/${size}x${size}/apps/${MY_PN}.png"
	done
	doicon -s 256 "usr/share/icons/hicolor/256x256@2/apps/${MY_PN}.png"
}
