# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

MY_PN="${PN%-bin}"
DESCRIPTION="An open-source cross-platform alternative to AirDrop"
HOMEPAGE="https://localsend.org"
SRC_URI="
	amd64? ( https://github.com/${MY_PN}/${MY_PN}/releases/download/v${PV}/LocalSend-${PV}-linux-x86-64.tar.gz )
	arm64? ( https://github.com/${MY_PN}/${MY_PN}/releases/download/v${PV}/LocalSend-${PV}-linux-arm-64.tar.gz )
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RESTRICT="bindist strip"

QA_PREBUILT="
	opt/localsend/localsend_app
	opt/localsend/lib/*.so
"

RDEPEND="
	>=sys-libs/glibc-2.34
	app-accessibility/at-spi2-core:2
	dev-libs/ayatana-ido:0
	dev-libs/glib:2
	dev-libs/libayatana-appindicator:0
	dev-libs/libayatana-indicator:3
	dev-libs/libdbusmenu:0[gtk3]
	media-libs/fontconfig
	media-libs/harfbuzz
	media-libs/libepoxy
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
	x11-misc/xdg-user-dirs
	x11-misc/xdg-utils
"
BDEPEND="dev-util/patchelf"

src_prepare() {
	default

	rm lib/libdartjni.so || die

	local plugin
	for plugin in lib/lib*_plugin.so; do
		patchelf --remove-rpath "${plugin}" || die
	done
}

src_install() {
	exeinto /opt/localsend
	doexe localsend_app

	cp -R "${S}/lib/" "${D}/opt/localsend" || die "install libraries failed"
	cp -R "${S}/data/" "${D}/opt/localsend" || die "install necessary assets failed"

	newicon "${S}"/data/flutter_assets/assets/img/logo.ico localsend.ico

	newmenu "${FILESDIR}"/localsend.desktop localsend.desktop

	dodir /opt/bin
	dosym ../localsend/localsend_app /opt/bin/localsend
}
