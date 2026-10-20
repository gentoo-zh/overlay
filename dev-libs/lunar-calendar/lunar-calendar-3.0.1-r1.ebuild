# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="a gtk+ calendar widget for chinese lunar library"
HOMEPAGE="https://github.com/yetist/lunar-calendar"
SRC_URI="https://github.com/yetist/lunar-calendar/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="doc vala introspection test"
RESTRICT="!test? ( test )"
RDEPEND="
	>=dev-python/pygobject-2.11.5
	dev-libs/glib:2
	dev-libs/lunar-date
	x11-libs/gtk+:3
	x11-libs/pango
"

DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
	sys-devel/gettext
	virtual/pkgconfig
	>=dev-util/intltool-0.35
	doc? ( dev-util/gtk-doc )
	vala? ( dev-lang/vala )
	introspection? ( dev-libs/gobject-introspection )"

DOCS="COPYING NEWS README.md"

src_configure(){
	local emesonargs=(
		$(meson_use doc docs)
		$(meson_use vala vapi)
		$(meson_use introspection introspection)
		$(meson_use test tests)
	)
	meson_src_configure
}

pkg_postinst(){
	einfo
	einfo "To make gtk applicants show lunar automaticly,"
	einfo "set the two envirent variables."
	einfo "GTK3_MODULES is for gtk3,and GTK_MODULES for gtk2."
	einfo "For example,write the two lines to .xprofile"
	einfo "export GTK3_MODULES=lunar-calendar-module"
	einfo "export GTK_MODULES=lunar-calendar-module"
	einfo
}
