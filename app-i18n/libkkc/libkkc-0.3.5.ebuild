# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic vala

DESCRIPTION="Japanese Kana Kanji conversion input method library"
HOMEPAGE="https://github.com/ueno/libkkc"
SRC_URI="https://github.com/ueno/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="nls static-libs"

RDEPEND="
	app-i18n/libkkc-data
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee:0.8
	dev-libs/marisa
	nls? ( virtual/libintl )
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(vala_depend)
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"

src_prepare() {
	default
	# The tests/ subdir builds a sample model with python2-only helpers and is
	# not installed; drop it so a normal build does not require python2.
	sed -i '/^SUBDIRS =/s/ tests//' Makefile.in || die
	vala_setup
}

src_configure() {
	# The vala-generated C predates modern gcc defaults; both diagnostics are
	# fatal since gcc 14, so keep them as warnings.
	append-cflags -Wno-error=int-conversion -Wno-error=incompatible-pointer-types

	# The bundled marisa-glib gobject-introspection build fails to link with
	# current toolchains and no reverse dependency needs the typelib.
	econf \
		--disable-introspection \
		$(use_enable nls) \
		$(use_enable static-libs static)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
