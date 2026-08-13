# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit gnome2-utils meson python-single-r1 xdg

DESCRIPTION="GTK-based text editor from the X-Apps project"
HOMEPAGE="https://github.com/linuxmint/xed"
SRC_URI="https://github.com/linuxmint/xed/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+spell"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	>=dev-libs/glib-2.40:2
	>=dev-libs/gobject-introspection-1.42
	>=dev-libs/libpeas-1.12:0[gtk,python,${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/libxml2-2.5:2=
	>=x11-libs/gtk+-3.19:3[introspection]
	>=x11-libs/gtksourceview-4.0.3:4
	>=x11-libs/xapp-1.9.0
	x11-libs/libX11
	x11-libs/pango
	spell? ( >=app-text/gspell-0.2.5:= )
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-util/glib-utils
	dev-util/intltool
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	default
	python_fix_shebang .

	# the Wayland app_id is the prgname xed, not the org.x.editor desktop file
	sed -i '/^Icon=/aStartupWMClass=xed' data/org.x.editor.desktop.in.in || die
}

src_configure() {
	local emesonargs=(
		-Ddocs=false
		-Denable_gvfs_metadata=false
		$(meson_use spell enable_spell)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	python_optimize
}

pkg_postinst() {
	gnome2_schemas_update
	xdg_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_pkg_postrm
}
