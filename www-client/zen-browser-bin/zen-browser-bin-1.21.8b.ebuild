# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop linux-info pax-utils xdg

DESCRIPTION="Experience tranquillity while browsing the web without people tracking you!"
HOMEPAGE="https://zen-browser.app/"
SRC_URI="
	amd64? (
		https://github.com/zen-browser/desktop/releases/download/${PV}/zen.linux-x86_64.tar.xz
			-> ${P}-amd64.tar.xz
	)
	arm64? (
		https://github.com/zen-browser/desktop/releases/download/${PV}/zen.linux-aarch64.tar.xz
			-> ${P}-arm64.tar.xz
	)
"

S="${WORKDIR}/zen"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="-* amd64 ~arm64"
IUSE="wayland"
RESTRICT="strip"

RDEPEND="
	|| (
		media-libs/libpulse
		media-sound/apulse
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	>=dev-libs/glib-2.26:2
	media-libs/alsa-lib
	media-libs/fontconfig
	>=media-libs/freetype-2.4.10
	sys-apps/dbus
	virtual/freedesktop-icon-theme
	>=x11-libs/cairo-1.10[X]
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3.11:3[X,wayland?]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libxcb
	>=x11-libs/pango-1.22.0
"

QA_PREBUILT="opt/${PN}/*"

pkg_setup() {
	use kernel_linux || return
	get_running_version || return
	linux_config_exists || return
	linux_chkconfig_present SECCOMP || \
		ewarn "CONFIG_SECCOMP not set! This system will be unable to play DRM-protected content."
}

src_install() {
	local destdir="/opt/${PN}"

	dodir "${destdir}"
	cp -a . "${ED}${destdir}" || die "failed to install zen tree"

	# Set proper permissions and pax-mark binaries
	local bin
	for bin in zen zen-bin updater glxtest vaapitest pingsender ; do
		[[ -f ${ED}${destdir}/${bin} ]] || continue
		fperms +x "${destdir}/${bin}"
		pax-mark m "${ED}${destdir}/${bin}"
	done

	# Install icons
	local icon size
	local icon_srcdir="${ED}${destdir}/browser/chrome/icons/default"
	if [[ -d ${icon_srcdir} ]] ; then
		for icon in "${icon_srcdir}"/default*.png ; do
			[[ -f ${icon} ]] || continue
			size=${icon%.png}
			size=${size##*/default}
			newicon -s ${size} "${icon}" ${PN}.png
		done
	fi

	# Install desktop entry
	domenu "${FILESDIR}/${PN}.desktop"

	# Install wrapper script
	newbin "${FILESDIR}/${PN}.sh" zen-browser

	# Update wrapper
	sed -i \
		-e "s:@MOZ_FIVE_HOME@:${EPREFIX}${destdir}:" \
		-e "s:@DEFAULT_WAYLAND@:$(usex wayland 1 0):" \
		"${ED}/usr/bin/zen-browser" || die
}

pkg_postinst() {
	xdg_pkg_postinst
}
