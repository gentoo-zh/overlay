# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="A cross-platform Apple Music experience built on Vue.js (Proprietary V3)"
HOMEPAGE="https://cider.sh/"

# Map the downloaded filename to a standard versioned name.
# ${A} will refer to the renamed file (${P}.deb).
_FILENAME="cider-v${PV}-linux-x64.deb"
SRC_URI="${_FILENAME} -> ${P}.deb"
S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE="trash-cli wayland"

# RESTRICT:
# - bindist: License forbids redistribution.
# - fetch: Manual download required.
# - strip: Do not strip bundled libraries (breaks integrity/DRM).
RESTRICT="bindist mirror fetch strip"

# RDEPEND:
# - gtk+:3[X,wayland?]: Ensure GTK supports X11 (required by binary) and optionally Wayland.
# - virtual/libudev: Required by Electron for device detection.
RDEPEND="
	app-accessibility/at-spi2-core
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X,wayland?]
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
	trash-cli? ( app-misc/trash-cli )
"

# Silence QA warnings about bundled libraries (libffmpeg, libEGL, etc.)
QA_PREBUILT="*"

pkg_nofetch() {
	einfo "Please purchase and download ${_FILENAME} from:"
	einfo "  ${HOMEPAGE}"
	einfo ""
	einfo "Rename and place it in DISTDIR:"
	einfo "  mv ${_FILENAME} /var/cache/distfiles/${P}.deb"
}

src_unpack() {
	# Unpack the deb file defined in SRC_URI.
	# The .deb contains 'data.tar.zst', which unpacker.eclass handles automatically.
	unpack_deb "${DISTDIR}/${A}"
}

src_install() {
	insinto /usr
	doins -r usr/share

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

	if use trash-cli; then
		elog "Trash support enabled via trash-cli."
	fi
}
