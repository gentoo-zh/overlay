# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature pax-utils unpacker xdg

DESCRIPTION="Antidetect browser for multi-account management"
HOMEPAGE="https://www.adspower.com/"

SRC_URI="https://version.adspower.net/software/linux-x64-global/${PV}/AdsPower-Global-${PV}-x64.deb"
S="${WORKDIR}"

LICENSE="AdsPower-EULA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	|| (
		sys-apps/systemd
		sys-apps/systemd-utils
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret[crypt]
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="*"

# Upstream installs the app under a directory name that contains a space.
ADSPOWER_DIR="AdsPower Global"

src_install() {
	# Install the application to /opt (without the space in the upstream name)
	mkdir -p "${ED}/opt/${PN}" || die
	cp -a "opt/${ADSPOWER_DIR}/." "${ED}/opt/${PN}/" || die

	# Drop bundled native modules for other platforms and libc implementations.
	# They are never loaded on glibc x86-64 and their sonames trip QA checks.
	local nm="${ED}/opt/${PN}/resources/app.asar.unpacked/node_modules"
	if [[ -d ${nm}/koffi/build/koffi ]]; then
		find "${nm}/koffi/build/koffi" -mindepth 1 -maxdepth 1 -type d \
			! -name linux_x64 -exec rm -r {} + || die
	fi
	# sharp is unusable here: upstream ships no glibc libvips for it.
	rm -rf "${nm}/@img" || die

	# Fix chrome-sandbox permissions
	fperms 4755 "/opt/${PN}/chrome-sandbox"

	# Allow V8's JIT to run under PaX/hardened kernels
	pax-mark m "${ED}/opt/${PN}/adspower_global"

	# Launcher on PATH
	dosym -r "/opt/${PN}/adspower_global" /usr/bin/${PN}

	# Desktop entry (point Exec at the launcher) and icons
	sed -i -e "s|^Exec=.*|Exec=${PN} %U|" \
		usr/share/applications/adspower_global.desktop || die
	domenu usr/share/applications/adspower_global.desktop
	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "The browser kernel is downloaded on first run into ~/.config/adspower_global."
	elog "It expects Qt5/GTK3 theme libraries; a Qt6/GTK4 desktop theme may crash or"
	elog "render it wrong. Fix: set Settings > Appearance > Theme > Classic."

	optfeature "system tray icon" dev-libs/libayatana-appindicator
}
