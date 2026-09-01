# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd xdg

DESCRIPTION="Bridge an iPhone to the Linux Wayland desktop"
HOMEPAGE="https://github.com/zackb/tether"
SRC_URI="https://github.com/zackb/tether/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

COMMON_DEPEND="
	dev-libs/glib:2
	dev-libs/openssl:0=
	dev-libs/wayland
	gui-libs/gtk-layer-shell
	net-dns/avahi[dbus]
	virtual/libintl
	x11-libs/gtk+:3[wayland]
	x11-libs/libnotify
"
DEPEND="
	${COMMON_DEPEND}
	>=dev-cpp/nlohmann_json-3.12.0
	test? ( >=dev-cpp/gtest-1.17.0 )
"
RDEPEND="
	!app-mobilephone/tether-bin
	${COMMON_DEPEND}
	>=net-wireless/bluez-5.86[deprecated,extra-tools,obex,readline]
"
BDEPEND="sys-devel/gettext"

PATCHES=(
	"${FILESDIR}/${P}-native-host.patch"
	"${FILESDIR}/${P}-system-dependencies.patch"
)

src_configure() {
	local mycmakeargs=(
		-DBLUETOOTHD_PATH="${EPREFIX}/usr/libexec/bluetooth/bluetoothd"
		-DBUILD_TESTING=$(usex test)
		-DCHROME_MESSAGING_DIR="${EPREFIX}/etc/chromium/native-messaging-hosts"
		-DGOOGLE_CHROME_MESSAGING_DIR="${EPREFIX}/etc/opt/chrome/native-messaging-hosts"
		-DMOZILLA_MESSAGING_DIR="${EPREFIX}/usr/$(get_libdir)/mozilla/native-messaging-hosts"
		-DSYSTEMD_UNIT_DIR="$(systemd_get_systemunitdir)"
		-DTETHER_BUILD_EXTENSIONS=OFF
		-DTETHER_VERSION="${PV}"
		-DTHUNDERBIRD_MESSAGING_DIR="${EPREFIX}/usr/$(get_libdir)/thunderbird/native-messaging-hosts"
	)
	cmake_src_configure
}

src_test() {
	local test_path="${T}/test-bin"
	mkdir "${test_path}" || die
	# Avoid making unit test results depend on the host's Bluetooth controller.
	ln -s "${EPREFIX}/bin/false" "${test_path}/btmgmt" || die
	PATH="${test_path}:${PATH}" cmake_src_test -j1
}

src_install() {
	cmake_src_install
	# The two-ring symbolic artwork appears as four blocks at common tray sizes.
	rm "${ED}"/usr/share/icons/hicolor/symbolic/apps/tether{,-offline,-unread}-symbolic.svg || die

	if [[ $(get_libdir) != lib ]]; then
		insinto /usr/lib/mozilla/native-messaging-hosts
		doins "${ED}/usr/$(get_libdir)/mozilla/native-messaging-hosts/com.tether.extension.json"
	fi
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
