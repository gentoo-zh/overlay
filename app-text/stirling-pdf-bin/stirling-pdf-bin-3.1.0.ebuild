# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Locally hosted, web-based PDF manipulation tool (Tauri desktop app)"
HOMEPAGE="https://www.stirling.com https://github.com/Stirling-Tools/Stirling-PDF"
SRC_URI="https://github.com/Stirling-Tools/Stirling-PDF/releases/download/v${PV}/Stirling-PDF-linux-x86_64.deb -> ${P}.deb"

S="${WORKDIR}"
LICENSE="MIT Stirling-PDF GPL-2-with-classpath-exception"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="bindist mirror strip"

RDEPEND="
	net-libs/webkit-gtk:4.1
	x11-libs/gtk+:3
"

src_install() {
	insinto /usr/lib
	doins -r "usr/lib/Stirling PDF"
	fperms +x \
		"/usr/lib/Stirling PDF/runtime/jre/bin/java" \
		"/usr/lib/Stirling PDF/runtime/jre/bin/jrunscript" \
		"/usr/lib/Stirling PDF/runtime/jre/bin/keytool" \
		"/usr/lib/Stirling PDF/runtime/jre/bin/rmiregistry" \
		"/usr/lib/Stirling PDF/runtime/jre/lib/jexec" \
		"/usr/lib/Stirling PDF/runtime/jre/lib/jspawnhelper"

	dobin usr/bin/Stirling-PDF
	domenu "usr/share/applications/Stirling PDF.desktop"
	local size
	for size in 16 32 64 128 192 512; do
		doicon -s ${size} "usr/share/icons/hicolor/${size}x${size}/apps/Stirling-PDF.png"
	done
}
