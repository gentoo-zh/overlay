# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# The rpm payload is gzip/uncompressed (no PayloadIs* marker), which rpm.eclass
# reports as 'none'; declare it so rpm_unpack uses a supported extractor without
# a QA notice.
RPM_COMPRESS_TYPE="none"

inherit rpm xdg desktop

DESCRIPTION="Official open-source two-factor authentication app by Proton"
HOMEPAGE="https://proton.me/authenticator"
SRC_URI="https://proton.me/download/authenticator/linux/ProtonAuthenticator-${PV}-1.x86_64.rpm"
S="${WORKDIR}"

# Based on ProtonMail ebuild - adjustments made for Authenticator
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	x11-libs/gtk+:3
	net-libs/webkit-gtk:4.1
"

QA_PREBUILT="usr/bin/proton-authenticator"

src_install() {
	# From RPM binaries
	dobin usr/bin/proton-authenticator

	# Desktop file
	domenu "usr/share/applications/Proton Authenticator.desktop"

	# Icons installation
	doicon -s 32 usr/share/icons/hicolor/32x32/apps/proton-authenticator.png
	doicon -s 128 usr/share/icons/hicolor/128x128/apps/proton-authenticator.png
	doicon -s 256 usr/share/icons/hicolor/256x256@2/apps/proton-authenticator.png
}
