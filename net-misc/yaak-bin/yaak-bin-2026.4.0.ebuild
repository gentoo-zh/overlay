# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg unpacker

DESCRIPTION="A fast, privacy-first API client for REST, GraphQL, SSE, WebSocket, and gRPC"
HOMEPAGE="https://yaak.app/"
URI_PREFIX="https://github.com/mountain-loop/yaak/releases/download/v${PV}/yaak_${PV}_"
SRC_URI="
	amd64? ( ${URI_PREFIX}amd64.deb )
"

S="${WORKDIR}"
LICENSE="MIT"

SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip"

RDEPEND="net-libs/webkit-gtk:4.1"

src_install() {
	dobin usr/bin/yaak-app-client
	insinto /usr/lib/yaak
	doins -r usr/lib/yaak/*
	fperms +x /usr/lib/yaak/vendored/node/yaaknode
	domenu usr/share/applications/yaak.desktop
	for icon in 32 128; do
		doicon -s ${icon} usr/share/icons/hicolor/${icon}x${icon}/apps/yaak-app-client.png
	done
	doicon -s 256 usr/share/icons/hicolor/256x256@2/apps/yaak-app-client.png
}
