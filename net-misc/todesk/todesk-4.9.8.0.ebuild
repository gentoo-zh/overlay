# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker systemd xdg

DESCRIPTION="Remote control and team work"
HOMEPAGE="https://www.todesk.com/"
SRC_URI="https://web.archive.org/web/20261020081749/https://dl.todesk.com/linux/todesk-v${PV}-amd64.deb"

S="${WORKDIR}"
LICENSE="todesk"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="systemd"
RESTRICT="strip mirror bindist"

RDEPEND="
	dev-libs/nspr
	dev-libs/nss
	systemd? ( sys-apps/systemd	)
	!systemd? ( sys-auth/elogind )
	media-libs/libpulse
	media-video/pipewire
	sys-fs/fuse:0
"
BDEPEND="dev-util/patchelf"

src_prepare() {
	default
	sed -i '/^Version=/d' usr/share/applications/todesk.desktop
}

src_install() {
	use systemd || patchelf --replace-needed libsystemd.so.0 libelogind.so.0 \
		opt/todesk/bin/{ToDesk,ToDesk_Service,ToDesk_Session} \
		|| die "failed to patch systemd library dependency"

	insinto /opt/todesk
	doins -r opt/todesk/bin
	doins -r opt/todesk/res
	fperms 0755 /opt/todesk/bin/{ToDesk,ToDesk_Service,ToDesk_Session,CrashReport}

	systemd_dounit etc/systemd/system/todeskd.service

	for size in 16 24 32 48 64 128 256 512; do
		doicon -s "${size}" usr/share/icons/hicolor/"${size}"x"${size}"/apps/todesk.png
	done

	domenu usr/share/applications/todesk.desktop
}
