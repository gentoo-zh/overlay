# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

MY_PV="$(ver_cut 4)"

# WPS 365 edition (the upstream ".365" build); see metadata.xml. Blocks the
# Personal edition app-office/wps-office over their shared install paths.
DESCRIPTION="WPS Office (WPS 365 edition), the Chinese office productivity suite"
HOMEPAGE="https://www.wps.cn/product/wpslinux/"

SRC_URI="
	amd64? ( https://pubwps-wps365-obs.wpscdn.cn/download/Linux/${MY_PV}/wps-office_${PV}.AK.preread.sw.indep365_763371_amd64.deb -> ${PN}_${PV}_amd64.deb )
	arm64? ( https://pubwps-wps365-obs.wpscdn.cn/download/Linux/${MY_PV}/wps-office_${PV}.AK.preread.sw.indep365_763373_arm64.deb -> ${PN}_${PV}_arm64.deb )
	loong? ( https://pubwps-wps365-obs.wpscdn.cn/download/Linux/${MY_PV}/wps-office_${PV}.AK.preread.sw.indep365_763378_loongarch64.deb -> ${PN}_${PV}_loongarch64.deb )
"

S="${WORKDIR}"

LICENSE="WPS-EULA"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong"
IUSE="systemd"

RESTRICT="strip mirror bindist" # mirror as explained at bug #547372

# Prebuilt bundled blob: keep the vendored libraries and their sonames as-is.
QA_PREBUILT="*"

BDEPEND="dev-util/patchelf"

# Runtime deps are the actual NEEDED sonames of the 12.x core binaries, the
# bundled Qt plugins and CEF, minus what is bundled under office6/. Regenerate
# with: scanelf -nBF '%n' -R office6 (then drop bundled/glibc sonames). Versus
# the Personal edition this adds media-libs/libpulse (the bundled Qt5 multimedia
# libraries under nplibs/ link libpulse).
RDEPEND="
	!!app-office/wps-office
	!!app-office/wps-office365-edu
	app-accessibility/at-spi2-core:2
	app-arch/bzip2:0
	app-arch/xz-utils
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libltdl
	dev-libs/nspr
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/libglvnd
	media-libs/libpulse
	media-libs/mesa[gbm(+)]
	arm64? ( media-libs/libva:0[X] )
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	systemd? ( || ( sys-apps/systemd sys-apps/systemd-utils ) )
	virtual/libusb:1
	virtual/zlib:0
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libdrm
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
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/pango
	loong? (
		virtual/loong-ow-compat
	)
"

src_prepare() {
	default

	local off="${S}/opt/kingsoft/wps-office/office6"

	# bug #7907: since 12.1.2.22570 the default component mode is "prome_fushion".
	# In that mode the et/wpp/wpspdf wrappers only re-exec the real binary when
	# "$1" is already "/prometheus", so a double-click (or `et file.xlsx`) never
	# opens the spreadsheet/slide/pdf. Drop the fushion guard so the wrapper
	# always launches the component. Reported fixed by upstream maintainers.
	local file
	for file in "${S}"/usr/bin/{et,wpp,wpspdf}; do
		grep -q '\[ 1 -eq ${gIsFushion} \] && \[ "$1" != "/prometheus" \]' "${file}" \
			|| die "launcher guard not found in ${file##*/}; re-check bug #7907 patch"
		sed -i -e 's|\[ 1 -eq ${gIsFushion} \] && \[ "$1" != "/prometheus" \]|[ "$1" != "/prometheus" ]|' \
			"${file}" || die "failed to patch ${file##*/} launcher"
	done

	# WPS bundles an X11-only Qt, so it runs under XWayland and only sees an input
	# method when QT_IM_MODULE is set. Set it per-app from XMODIFIERS (fcitx/ibus)
	# so IME works in the document area; setting it globally would break native
	# Wayland apps on KDE (per the fcitx5 docs), so do it only in these launchers.
	sed -i -e '1a export QT_IM_MODULE="${QT_IM_MODULE:-${XMODIFIERS#@im=}}"' \
		"${S}"/usr/bin/{et,wpp,wps,wpspdf} || die

	# The .desktop files list only a sub-category (Spreadsheet, WordProcessor...)
	# with no Office main category, so menus file them under "Uncategorized".
	sed -i -e 's/^Categories=/Categories=Office;/' \
		"${S}"/usr/share/applications/*.desktop || die

	# Drop components that pull in libraries not shippable on Gentoo:
	#  - libpeony-wpsprint-menu-plugin.so needs the UKUI/Kylin Peony file manager
	#  - KPacketInstall is a .deb self-installer wanting system Qt5
	#  - libFontWatermark.so needs libmysqlclient.so.18
	#  - lib{et,wpp,wps}uofrw.so are stale UOF read/write shims with no consumers
	rm -f "${off}"/libpeony-wpsprint-menu-plugin.so || die
	rm -f "${off}"/KPacketInstall || die
	rm -f "${off}"/libFontWatermark.so || die
	rm -f "${off}"/lib{et,wpp,wps}uofrw.so || die

	# librpc{et,wpp,wps}api_sysqt5.so link the system Qt5 stack (libQt5Core / Gui
	# / Network / Widgets / Xml.so.5); keeping them would fail the unresolved-
	# soname QA check or force the whole dev-qt Qt5 stack into RDEPEND. Drop them:
	# nothing loads them at runtime (only cfgs/wpsupgrade/ lists them), and the
	# default librpc*api.so (bundled Qt4) and librpc*api_wpsqt.so (bundled Qt5)
	# variants provide the same RPC API. (amd64-only .deb; rm -f no-ops elsewhere.)
	rm -f "${off}"/librpc{et,wpp,wps}api_sysqt5.so || die

	# Use the system C++ runtime instead of the bundled one.
	rm "${off}"/libstdc++.so* || die

	# libwpscompress links the Debian soname libbz2.so.1.0; Gentoo ships libbz2.so.1.
	rm -f "${off}"/libbz2.so* || die
	patchelf --replace-needed libbz2.so.1.0 libbz2.so.1 \
		"${off}"/addons/wpscompress/libwpscompress.so || die

	# Portage's unresolved-soname QA check inspects each ELF on its own and cannot
	# see office6/'s core libraries from the addon sub-directories (at runtime the
	# host process pre-loads them into the global scope). Give every bundled object
	# an $ORIGIN-relative RPATH back to office6/ and the sibling addon dirs that
	# other addons link against; --force-rpath keeps the inherited DT_RPATH tag.
	local f rel base rpath d
	while IFS= read -r -d '' f; do
		patchelf --print-rpath "${f}" &>/dev/null || continue  # ELF objects only
		base='$ORIGIN' rel=${f#"${off}/"}
		while [[ ${rel} == */* ]]; do base+=/..; rel=${rel#*/}; done
		rpath="\$ORIGIN:\$ORIGIN/..:${base}"
		for d in cef kcef kappessframework kpubaigcbox ksoftbus ksoftbuscore \
			knewshare kwpscloudmodule wpsbox kpdf2wordv3/ofd2pdf; do
			rpath+=":${base}/addons/${d}"
		done
		patchelf --force-rpath --set-rpath "${rpath}" "${f}" || die
	done < <(find "${off}" -type f \( -executable -o -name '*.so*' \) -print0)
}

src_install() {
	dobin "${S}"/usr/bin/*

	insinto /usr/share
	doins -r "${S}"/usr/share/{applications,desktop-directories,icons,mime,templates}

	insinto /opt/kingsoft/wps-office
	use systemd || { rm "${S}"/opt/kingsoft/wps-office/office6/libdbus-1.so* || die ; }
	doins -r "${S}"/opt/kingsoft/wps-office/{office6,templates}

	# doins forces 0644, which strips the executable bit off the many helper
	# binaries under office6/ (wps, et, wpsofd, wpsquery, ksoapirpcengine, ...).
	# Restore 0755 on everything that shipped executable in the .deb.
	local x
	while IFS= read -r -d '' x; do
		fperms 0755 "${x#"${S}"}"
	done < <(find "${S}"/opt/kingsoft/wps-office/office6 -type f -perm -u+x -print0)
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "WPS 365 opens a sign-in dialog on first launch that has no close"
	elog "button; press Esc to dismiss it. WPS 365 may require an account, so"
	elog "some features may be unavailable without signing in. If you do not"
	elog "want to sign in at all, app-office/wps-office365-edu (the education"
	elog "edition) works fully without an account."
	elog ""
	elog "WPS 365 首次启动会弹出登入框且无关闭按钮，按 Esc 可关闭；"
	elog "但 WPS 365 可能强制要求登入，未登入可能无法使用部分功能。"
	elog "完全不想登入的话，可以改用 app-office/wps-office365-edu（教育版），"
	elog "教育版不需要登入即可正常使用。"
}
