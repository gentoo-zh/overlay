# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3 or later

EAPI=8

COMMIT="f240b2ec7d5cdacb8fdcc553703420dc5101ffdb"

inherit meson vala

DESCRIPTION="Utility library for GNOME apps"
HOMEPAGE="https://gitlab.gnome.org/raggesilver/marble"
SRC_URI="https://gitlab.gnome.org/raggesilver/marble/-/archive/${COMMIT}/marble-${COMMIT}.tar.bz2"

S="${WORKDIR}/marble-${COMMIT}"

LICENSE="GPL-3+"
SLOT="0/2"
KEYWORDS="~amd64"

DEPEND="
	>=gui-libs/gtk-4.0:4
"
RDEPEND="${DEPEND}"

BDEPEND="
	>=dev-lang/vala-0.56
	dev-libs/gobject-introspection
	virtual/pkgconfig
"

# Fix CSS provider API compatibility across Vala versions
# https://gitlab.gnome.org/raggesilver/marble/-/issues/12
PATCHES=(
	"${FILESDIR}/${PN}-2.0.0-css-provider.patch"
	"${FILESDIR}/${PN}-2.0.0-settings-strv.patch"
)

src_prepare() {
	default
	vala_setup
}

src_configure() {
	meson_src_configure
}

src_install() {
	meson_src_install
}
