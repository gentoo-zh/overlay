# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Void Editor - AI Code Editor"
HOMEPAGE="https://voideditor.com"

SRC_URI="
	amd64? ( https://github.com/voideditor/binaries/releases/download/${PV}/Void-linux-x64-${PV}.tar.gz )
	arm64? ( https://github.com/voideditor/binaries/releases/download/${PV}/Void-linux-arm64-${PV}.tar.gz )
"
S="${WORKDIR}"

LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror strip"

RDEPEND="
	app-crypt/libsecret
	x11-libs/libX11
	x11-libs/libxkbfile
	sys-apps/ripgrep
"

QA_PREBUILT="
	opt/void/*
"

src_install() {
	insinto /opt/void
	doins -r "${S}"/*
	fperms +x /opt/void/void
	dosym ../../opt/void/void /usr/bin/void

	domenu "${FILESDIR}"/void-editor.desktop
	doicon -s 256 "${S}/resources/app/resources/linux/code.png"
	dodoc "${S}/LICENSES.chromium.html"
}
