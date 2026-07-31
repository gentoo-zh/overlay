# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature unpacker xdg

DESCRIPTION="A cross-platform Apple Music experience built on Vue.js (Proprietary V4)"
HOMEPAGE="https://cider.sh/"

SRC_URI="https://repo.cider.sh/apt/pool/main/cider-v${PV}-linux-x64.deb"
S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"

# RESTRICT:
# - bindist: License forbids redistribution.
# - strip: Do not strip bundled libraries (breaks integrity/DRM).
RESTRICT="bindist mirror strip"

# RDEPEND:
# - gtk+:3[X]: Ensure GTK supports X11 (required by the binary).
# - virtual/libudev: Required by Electron for device detection.
RDEPEND="
	app-accessibility/at-spi2-core
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/libudev:=
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-libs/libnotify
	x11-misc/xdg-utils
"

# Silence QA warnings about the bundled ELF files.
QA_PREBUILT="
	/opt/cider/Cider
	/opt/cider/chrome-sandbox
	/opt/cider/chrome_crashpad_handler
	/opt/cider/libEGL.so
	/opt/cider/libGLESv2.so
	/opt/cider/libffmpeg.so
	/opt/cider/libvk_swiftshader.so
	/opt/cider/libvulkan.so.1
"

src_unpack() {
	# Unpack the deb file defined in SRC_URI.
	# The .deb contains 'data.tar.zst', which unpacker.eclass handles automatically.
	unpack_deb "${DISTDIR}/${A}"
}

src_install() {
	domenu usr/share/applications/cider.desktop
	doicon usr/share/pixmaps/cider.png

	insinto /opt
	doins -r usr/lib/cider

	dosym ../../opt/cider/Cider /usr/bin/cider

	fperms +x /opt/cider/Cider

	# Chrome Sandbox (Requires SUID)
	if [[ -f "${D}/opt/cider/chrome-sandbox" ]]; then
		fperms 4755 /opt/cider/chrome-sandbox
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "Wayland support" "x11-libs/gtk+:3[wayland]"
	optfeature "Trash support" app-misc/trash-cli
}
