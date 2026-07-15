# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="WPS Office is an office productivity suite, Here is the Chinese version"
HOMEPAGE="https://www.wps.cn/product/wpslinux/"

SRC_URI="
	amd64? ( https://github.com/peeweep/gentoo-go-deps/releases/download/${PN}_${PV}/${PN}_${PV}_amd64.deb )
	arm64? ( https://github.com/peeweep/gentoo-go-deps/releases/download/${PN}_${PV}/${PN}_${PV}_arm64.deb )
	loong? ( https://github.com/peeweep/gentoo-go-deps/releases/download/${PN}_${PV}/${PN}_${PV}_loongarch64.deb )
"

S="${WORKDIR}"

LICENSE="WPS-EULA"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong"
IUSE="systemd"

RESTRICT="strip mirror bindist" # mirror as explained at bug #547372
QA_PREBUILT="*"

BDEPEND="dev-util/patchelf"

# Runtime deps are the actual NEEDED sonames of the 11.x core binaries, the
# bundled Qt5 (Kso) libraries and CEF, minus what is bundled under office6/.
# The previous list was still the deps of the 2017 10.1.0.5707 rpm. Regenerate
# with: scanelf -nBF '%n' -R office6 (then drop bundled/glibc sonames).
RDEPEND="
	app-accessibility/at-spi2-core:2
	app-arch/xz-utils
	dev-db/sqlite
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libltdl
	dev-libs/libxml2-compat:2
	dev-libs/libxslt
	dev-libs/nspr
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/libglvnd
	media-libs/mesa[gbm(+)]
	media-libs/tiff-compat:4
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	systemd? ( || ( sys-apps/systemd sys-apps/systemd-utils ) )
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libXv
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/pango
	loong? (
		virtual/loong-ow-compat
	)
"

src_install() {
	# WPS bundles an X11-only Qt, so it runs under XWayland and only sees an input
	# method when QT_IM_MODULE is set. Set it per-app from XMODIFIERS (fcitx/ibus)
	# so IME works in the document area; setting it globally would break native
	# Wayland apps on KDE (per the fcitx5 docs), so do it only in these launchers.
	sed -i -e '1a export QT_IM_MODULE="${QT_IM_MODULE:-${XMODIFIERS#@im=}}"' \
		"${S}"/usr/bin/{et,wpp,wps,wpspdf} || die

	dobin "${S}"/usr/bin/*

	insinto /usr/share
	doins -r "${S}"/usr/share/{applications,desktop-directories,icons,mime,templates}

	insinto /opt/kingsoft/wps-office
	use systemd || { rm "${S}"/opt/kingsoft/wps-office/office6/libdbus-1.so* || die ; }
	# Use the system C++ runtime instead of the bundled one.
	rm "${S}"/opt/kingsoft/wps-office/office6/libstdc++.so* || die

	# The default (Qt4) and _sysqt5 (system Qt5) RPC API plugin variants need a
	# system Qt that Gentoo no longer ships (Qt4) or that would be a heavy extra
	# dependency; the bundled _wpsqt variant provides the same API through the
	# bundled Qt, so drop the two unusable variants.
	rm -f "${S}"/opt/kingsoft/wps-office/office6/librpc{et,wpp,wps}api.so || die
	rm -f "${S}"/opt/kingsoft/wps-office/office6/librpc{et,wpp,wps}api_sysqt5.so || die

	# libpdfbatchcompressionapp.so needs libkappessframework.so, which this build
	# does not ship; drop the dangling wrapper (libpdfbatchcompression.so stays).
	rm -f "${S}"/opt/kingsoft/wps-office/office6/addons/pdfbatchcompression/libpdfbatchcompressionapp.so || die

	# libicu*/libv8* were linked against the unversioned soname libc++.so; the
	# blob bundles libc++.so.1 (soname libc++.so.1), so point them at the bundled
	# versioned soname instead of requiring a system libc++.so.
	local f
	while IFS= read -r -d '' f; do
		patchelf --print-needed "${f}" 2>/dev/null | grep -qxF 'libc++.so' \
			&& { patchelf --replace-needed libc++.so libc++.so.1 "${f}" || die ; }
	done < <(find "${S}"/opt/kingsoft/wps-office/office6 -type f -name '*.so*' -print0)

	doins -r "${S}"/opt/kingsoft/wps-office/{office6,templates}

	# doins forces 0644, which strips the executable bit off the many helper
	# binaries under office6/ (wps, et, wpsofd, ksoapirpcengine, ...). Restore
	# 0755 on everything that shipped executable in the .deb.
	local x
	while IFS= read -r -d '' x; do
		fperms 0755 "${x#"${S}"}"
	done < <(find "${S}"/opt/kingsoft/wps-office/office6 -type f -perm -u+x -print0)
}
