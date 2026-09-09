# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95"

inherit cargo desktop optfeature xdg

DESCRIPTION="A fast open-source alternative of VRChat Creator Companion (VCC)"
HOMEPAGE="https://github.com/vrc-get/vrc-get"
SRC_URI="
	https://github.com/vrc-get/vrc-get/archive/refs/tags/gui-v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/alcom/releases/download/${P}/${P}-crates.tar.xz
	https://github.com/gentoo-zh-drafts/alcom/releases/download/${P}/${P}-web.tar.xz
"

S="${WORKDIR}/vrc-get-gui-v${PV}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD
	CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-libs/glib:2
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
"

QA_FLAGS_IGNORED="usr/bin/${PN}"

src_prepare() {
	default

	# Prebuilt frontend ships as top-level out/; move into the crate dir so
	# tauri-build embeds it (Tauri.toml sets frontendDist = "out").
	mv "${WORKDIR}/out" "${S}/vrc-get-gui/" || die
}

src_configure() {
	myfeatures=( "custom-protocol" "no-self-updater" )
	cargo_src_configure
}

src_compile() {
	cargo_src_compile --frozen --locked -p vrc-get-gui
}

src_test() {
	cargo_src_test -p vrc-get-gui
}

src_install() {
	newbin "$(cargo_target_dir)/ALCOM" "${PN}"

	local size
	for size in 32 64 128; do
		newicon -s "${size}" "${S}/vrc-get-gui/icons/${size}x${size}.png" alcom.png
	done
	newicon -s 256 "${S}/vrc-get-gui/icons/128x128@2x.png" alcom.png

	sed -e 's/{{exec}}/\/usr\/bin\/alcom/g' "${S}/vrc-get-gui/bundle/alcom.desktop" \
		> "${T}/alcom.desktop" || die
	domenu "${T}/alcom.desktop"

	einstalldocs
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "editing Unity project" dev-games/unityhub
}
