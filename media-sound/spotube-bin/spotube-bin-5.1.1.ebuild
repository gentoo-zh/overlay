# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg
DESCRIPTION="A lightweight Spotify client using YouTube as audio source"
HOMEPAGE="https://github.com/KRTirtho/spotube"
SRC_URI="https://github.com/KRTirtho/spotube/releases/download/v${PV}/spotube-linux-${PV}-x86_64.tar.xz"

S="${WORKDIR}"

LICENSE="BSD-4"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
		dev-util/patchelf
"
RDEPEND="
		dev-libs/libayatana-appindicator
		media-video/mpv
		net-libs/libsoup:3.0
		net-libs/webkit-gtk:4.1
		x11-libs/libnotify
"

RESTRICT="strip"

src_install() {
	insinto /opt/spotube/
	doins -r data lib
	exeinto /opt/spotube
	doexe spotube
	dosym -r /opt/spotube/spotube /usr/bin/spotube
	doins "${S}/spotube-logo.png"
	sed -i -e 's|^Exec=.*|Exec=/opt/spotube/spotube|' \
		-i -e 's|^Icon=.*|Icon=/opt/spotube/spotube-logo.png|' \
		"${S}"/spotube.desktop || die
	for i in 16 32 64 128 256; do
	    doicon -s "$i" "${S}"/spotube-logo.png
	done
	domenu "${S}/spotube.desktop"
	patchelf --replace-needed "libappindicator3.so.1" "libayatana-appindicator3.so.1" \
	"${ED}/opt/spotube/lib/libtray_manager_plugin.so" || die
}
