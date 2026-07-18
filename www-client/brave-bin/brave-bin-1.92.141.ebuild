# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar az bg bn bs ca cs da de el en-GB en-US es es-419 et fa fi fil fr
	gu he hi hr hu id it ja ka kk km kn ko lo lt lv mk ml mn mr ms my nb nl pl pt-BR pt-PT ro ru
	si sk sl sq sr-Latn sr sv sw ta te th tr uk ur uz vi zh-CN zh-TW"

inherit chromium-2 desktop pax-utils unpacker xdg

MY_PN=${PN/-bin}-browser
DESCRIPTION="Web browser that blocks ads and trackers by default"
HOMEPAGE="https://brave.com/"
SRC_URI="
	amd64? ( https://github.com/${PN/-bin}/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_amd64.deb )
	arm64? ( https://github.com/${PN/-bin}/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_arm64.deb )
"

S=${WORKDIR}

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

IUSE="qt6 selinux"
RESTRICT="bindist strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	>=dev-libs/nss-3.26
	media-fonts/liberation-fonts
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	sys-libs/glibc
	sys-libs/libcap
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	|| (
		x11-libs/gtk+:3[X]
		gui-libs/gtk:4[X]
	)
	x11-libs/libdrm
	>=x11-libs/libX11-1.5.0
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
	x11-misc/xdg-utils
	qt6? ( dev-qt/qtbase:6[gui,widgets] )
	selinux? ( sec-policy/selinux-chromium )
"

QA_PREBUILT="*"
QA_DESKTOP_FILE="usr/share/applications/brave-browser.*\\.desktop"
BRAVE_HOME="opt/brave.com/brave"

pkg_setup() {
	[[ -e /usr/src/linux ]] || return
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	:
}

src_install() {
	dodir /
	cd "${ED}" || die
	unpacker

	# The appdata directory is deprecated.
	mv usr/share/{appdata,metainfo}/ || die

	# Remove cron job for updating from Debian repos.
	rm -r ${BRAVE_HOME}/cron/ || die
	rm -r etc || die

	# Rename docs directory to our needs.
	mv usr/share/doc/${MY_PN} usr/share/doc/${PF} || die

	# Remove unnecessary .desktop file and empty directory
	rm -r usr/share/doc/${MY_PN}-stable || die
	rm usr/share/applications/com.brave.Browser.desktop || die

	# Decompress the docs.
	gzip -d usr/share/doc/${PF}/changelog.gz || die
	gzip -d usr/share/man/man1/${MY_PN}-stable.1.gz || die
	if [[ -L usr/share/man/man1/brave-browser.1.gz ]]; then
	    rm usr/share/man/man1/brave-browser.1.gz || die
	    dosym ${MY_PN}-stable.1 usr/share/man/man1/brave-browser.1
	fi

	# Remove unused language packs
	pushd "${BRAVE_HOME}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	rm "${BRAVE_HOME}/libqt5_shim.so" || die
	if ! use qt6; then
		rm "${BRAVE_HOME}/libqt6_shim.so" || die
	fi

	local logo size
	for logo in "${ED}"/${BRAVE_HOME}/product_logo_*.png; do
	    size=${logo##*_}
		size=${size%.*}
		newicon -s "${size}" "${logo}" ${PN/-bin/-browser}.png
	done

	pax-mark m "${BRAVE_HOME}/brave"
	fperms 4711 "/${BRAVE_HOME}/chrome-sandbox"
}
