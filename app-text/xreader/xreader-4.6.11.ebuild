# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2-utils meson xdg

DESCRIPTION="Document viewer for the X-Apps project"
HOMEPAGE="https://github.com/linuxmint/xreader"
SRC_URI="https://github.com/linuxmint/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+ LGPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cups djvu dvi +introspection keyring +postscript t1lib tiff xps"
REQUIRED_USE="t1lib? ( dvi )"

DEPEND="
	app-accessibility/at-spi2-core:2
	>=app-arch/libarchive-3.6.0:=
	app-text/poppler:=[cairo]
	>=dev-libs/glib-2.36.0:2
	dev-libs/libxml2:2=
	virtual/zlib:=
	>=x11-libs/cairo-1.14.0
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3.22.0:3[X,cups?,introspection?]
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/pango
	>=x11-libs/xapp-2.5.0
	djvu? ( >=app-text/djvu-3.5.17:= )
	dvi? (
		>=app-text/libspectre-0.2
		dev-libs/kpathsea:=
		t1lib? ( media-libs/t1lib:5 )
	)
	introspection? ( dev-libs/gobject-introspection:= )
	keyring? ( >=app-crypt/libsecret-0.5 )
	postscript? ( >=app-text/libspectre-0.2 )
	tiff? ( media-libs/tiff:= )
	xps? ( >=app-text/libgxps-0.2.1:= )
"
RDEPEND="${DEPEND}
	x11-themes/xapp-symbolic-icon-theme
"
BDEPEND="
	dev-util/gdbus-codegen
	dev-util/glib-utils
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Dcomics=true
		$(meson_use djvu)
		$(meson_use dvi)
		$(meson_use t1lib)
		-Dpdf=true
		-Dpixbuf=true
		$(meson_use postscript ps)
		$(meson_use tiff)
		$(meson_use xps)
		$(meson_use cups gtk_unix_print)
		$(meson_use keyring)
		-Dpreviewer=true
		-Dthumbnailer=true
		-Ddocs=false
		-Dhelp_files=true
		$(meson_use introspection)
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
