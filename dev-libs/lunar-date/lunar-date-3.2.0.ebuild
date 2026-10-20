# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Chinese Lunar Library"
HOMEPAGE="https://github.com/yetist/lunar-date"
SRC_URI="https://github.com/yetist/lunar-date/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="+dbus doc introspection test"

REQUIRED_USE="doc? ( introspection )"

RESTRICT="!test? ( test )"

RDEPEND=">=dev-python/pygobject-2.11.5"

DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
	sys-devel/gettext
	virtual/pkgconfig
	>=dev-util/intltool-0.35
	doc? (
		dev-util/gi-docgen
		dev-util/gtk-doc
	)
	introspection? ( dev-libs/gobject-introspection )"

DOCS="AUTHORS COPYING NEWS README.md"

src_configure(){
	local emesonargs=(
		$(meson_use dbus service)
		$(meson_use doc docs)
		$(meson_use introspection introspection)
		$(meson_use test tests)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if use doc; then
		mkdir -p "${ED}"/usr/share/gtk-doc/html/ || die
		mv "${ED}"/usr/share/doc/${PN} "${ED}"/usr/share/gtk-doc/html/ || die
	fi
}
