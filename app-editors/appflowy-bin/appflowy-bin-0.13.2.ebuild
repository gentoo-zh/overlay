# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN="AppFlowy"

DESCRIPTION="AppFlowy is an open-source alternative to Notion"
HOMEPAGE="https://appflowy.com/"
SRC_URI="
	https://github.com/AppFlowy-IO/AppFlowy/releases/download/${PV}/AppFlowy-${PV}-linux-x86_64.tar.gz
"
S="${WORKDIR}/${MY_PN}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="llvm-libunwind"

DEPEND="
	app-accessibility/at-spi2-core:2
	app-arch/bzip2
	app-arch/lz4
	app-crypt/mit-krb5
	dev-libs/glib:2
	dev-libs/wayland
	dev-libs/openssl:0/3
	dev-libs/keybinder:3
	media-video/mpv:0[libmpv]
	media-libs/gst-plugins-base
	media-libs/harfbuzz
	media-libs/libepoxy
	media-libs/libpulse
	media-libs/libva
	llvm-libunwind? ( llvm-runtimes/libunwind:= )
	!llvm-libunwind? ( sys-libs/libunwind:= )
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libXinerama
	x11-libs/libnotify
	x11-libs/libxkbcommon
	x11-libs/libvdpau
	x11-libs/pango
	x11-misc/xdg-user-dirs[gtk]
"
RDEPEND="${DEPEND}"
BDEPEND="dev-util/patchelf"

QA_PRESTRIPPED="
	/opt/${PN}/lib/libapp.so
	/opt/${PN}/lib/libflutter_linux_gtk.so
"
QA_PREBUILT="*"

src_install() {
	local f
	while IFS= read -r -d '' f; do
		[[ -L ${f} ]] && continue
		patchelf --print-needed "${f}" 2>/dev/null | grep -qxF 'libbz2.so.1.0' || continue
		patchelf --replace-needed libbz2.so.1.0 libbz2.so.1 "${f}" || die
	done < <(find "${S}" -type f -print0)

	rm lib/libmpv.so.{1,2} || die

	insinto "/opt/${PN}"
	doins -r data/ lib/ AppFlowy
	dosym -r /usr/lib64/libmpv.so.2 "/opt/${PN}/lib/libmpv.so"
	dosym -r /usr/lib64/libmpv.so.2 "/opt/${PN}/lib/libmpv.so.1"
	dosym -r /usr/lib64/libmpv.so.2 "/opt/${PN}/lib/libmpv.so.2"

	fperms +x /opt/${PN}/AppFlowy

	domenu "${FILESDIR}/AppFlowy.desktop"
	doicon -s scalable data/flutter_assets/assets/images/flowy_logo.svg
}
