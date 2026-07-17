# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

DESCRIPTION="GUI file manager, fork of GNOME Files (Nautilus); supports SSH, FTP, WebDav"
HOMEPAGE="https://wiki.mate-desktop.org/mate-desktop/applications/caja/"
SRC_URI="https://github.com/Samueru-sama/caja-appimage-test/releases/download/${PV}-3/Caja-${PV}-3-anylinux-x86_64.AppImage"

S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip"

QA_PREBUILT="*"
# Against "QA Notice: Files built without respecting CFLAGS have been detected"

RDEPEND="sys-fs/fuse"

src_install() {
	newbin "${DISTDIR}/Caja-${PV}-3-anylinux-x86_64.AppImage" caja-appimage
	domenu "${FILESDIR}/caja-appimage.desktop"
}
