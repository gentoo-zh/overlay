# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Open source, plugin powered music streaming client"
HOMEPAGE="https://github.com/team-spotube/spotube"
SRC_URI="
	amd64? ( https://github.com/team-spotube/spotube/releases/download/v${PV}/spotube-linux-${PV}-x86_64.tar.xz )
	arm64? ( https://github.com/team-spotube/spotube/releases/download/v${PV}/spotube-linux-${PV}-aarch64.tar.xz )
"
S="${WORKDIR}"

LICENSE="AGPL-3+ Apache-2.0 GPL-2-with-classpath-exception"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	dev-libs/glib:2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libglvnd
	<media-video/vlc-4[ffmpeg,ssl]
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	virtual/zlib:=
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/pango
"

RESTRICT="strip"

QA_PREBUILT="opt/spotube/*"

src_install() {
	cd "spotube-linux-${PV}-$(usex arm64 aarch64 x86_64)" || die

	exeinto /opt/spotube
	doexe app/spotube app/*.so
	exeinto /opt/spotube/lib
	doexe app/lib/*.so
	dosym -r /opt/spotube/spotube /usr/bin/spotube

	domenu share/applications/org.spotube.spotube.desktop
	doicon -s 512 share/icons/hicolor/512x512/apps/org.spotube.spotube.png
	insinto /usr/share/metainfo
	doins share/metainfo/org.spotube.spotube.metainfo.xml
}
