# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop systemd unpacker xdg

DESCRIPTION="Prebuilt bridge between an iPhone and the Linux Wayland desktop"
HOMEPAGE="https://github.com/zackb/tether"
SRC_URI="amd64? (
	https://github.com/zackb/tether/releases/download/v${PV}/tether-${PV}.deb
		-> ${P}-amd64.deb
)"

S="${WORKDIR}"

LICENSE="MIT MPL-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip"

RDEPEND="
	!app-mobilephone/tether
	dev-libs/glib:2
	dev-libs/openssl:0/3
	dev-libs/wayland
	gui-libs/gtk-layer-shell
	net-dns/avahi[dbus]
	>=net-wireless/bluez-5.86[deprecated,extra-tools,obex,readline]
	>=sys-devel/gcc-13.2.0:*
	>=sys-libs/glibc-2.38
	x11-libs/gtk+:3[wayland]
	x11-libs/libnotify
"

QA_PREBUILT="
	usr/bin/tether
	usr/bin/tether-dialog
	usr/bin/tether-gtk
	usr/bin/tetherd
"

src_prepare() {
	default
	sed -i \
		-e '1s:/bin/bash:/bin/sh:' \
		-e 's: 2>> /tmp/tether-native.log::' \
		usr/bin/tether-native-host || die
	sed -i \
		-e "s:/usr/lib/bluetooth/bluetoothd:${EPREFIX}/usr/libexec/bluetooth/bluetoothd:" \
		usr/share/tether/bluetooth-experimental.conf || die
	# The two-ring symbolic artwork appears as four blocks at common tray sizes.
	rm usr/share/icons/hicolor/symbolic/apps/tether{,-offline,-unread}-symbolic.svg || die
}

src_install() {
	dobin usr/bin/{tether,tether-dialog,tether-gtk,tether-native-host,tetherd}

	insinto /etc/chromium/native-messaging-hosts
	doins etc/chromium/native-messaging-hosts/com.tether.extension.json
	insinto /etc/opt/chrome/native-messaging-hosts
	doins etc/opt/chrome/native-messaging-hosts/com.tether.extension.json

	local manifest=usr/lib/x86_64-linux-gnu/mozilla/native-messaging-hosts/com.tether.extension.json
	insinto "/usr/$(get_libdir)/mozilla/native-messaging-hosts"
	doins "${manifest}"
	if [[ $(get_libdir) != lib ]]; then
		insinto /usr/lib/mozilla/native-messaging-hosts
		doins "${manifest}"
	fi
	insinto "/usr/$(get_libdir)/thunderbird/native-messaging-hosts"
	doins usr/lib/x86_64-linux-gnu/thunderbird/native-messaging-hosts/com.tether.extension.json

	domenu usr/share/applications/tether-gtk.desktop
	insinto /usr/share
	doins -r usr/share/{icons,locale}
	insinto /usr/share/tether
	doins usr/share/tether/bluetooth-experimental.conf
	doman usr/share/man/man1/{tether,tether-gtk}.1 usr/share/man/man8/tetherd.8
	systemd_dounit usr/lib/systemd/system/tether-btclass@.service
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "The iPhone app uses avahi-daemon to discover this computer over Wi-Fi."
	if has_version sys-apps/systemd; then
		elog "Enable it with: systemctl enable --now avahi-daemon"
	else
		elog "Enable it with: rc-update add avahi-daemon default"
		elog "Then start it with: rc-service avahi-daemon start"

		elog "Tether's Bluetooth setup helper currently supports systemd only."
		elog "Wi-Fi pairing, clipboard synchronization, and file transfer remain available on OpenRC."
	fi
}
