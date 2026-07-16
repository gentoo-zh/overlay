# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..14} )

inherit python-r1 autotools optfeature xdg

DESCRIPTION="Standalone lyrics fetcher/displayer (windowed and OSD mode)"
HOMEPAGE="https://github.com/osdlyrics/osdlyrics"

LICENSE="GPL-3"
SLOT="0"

if [[ "${PV}" == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/osdlyrics/osdlyrics.git"
else
	KEYWORDS="~amd64"
	SRC_URI="https://github.com/osdlyrics/osdlyrics/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

IUSE="gnome indicator"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	x11-libs/libnotify
	x11-libs/gtk+:2
	x11-themes/hicolor-icon-theme
	dev-libs/dbus-glib
	dev-db/sqlite
	dev-util/desktop-file-utils
	dev-python/chardet[${PYTHON_USEDEP}]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
	dev-python/pycurl[${PYTHON_USEDEP}]
	gnome? ( dev-libs/gobject-introspection )
	indicator? ( dev-libs/libayatana-appindicator )
"

DEPEND="
	dev-util/intltool
	dev-vcs/git
	${RDEPEND}
"

src_prepare() {
	default
	eautoreconf
	python_copy_sources
}

src_configure() {
	configuring() {
		local myconf=(
			--prefix="${EPREFIX}/usr" PYTHON="${PYTHON}"
			$(use_enable indicator appindicator)
		)
		econf "${myconf[@]}"
	}
	python_foreach_impl run_in_build_dir configuring
}

src_compile() {
	python_foreach_impl run_in_build_dir default
}

src_install() {
	python_foreach_impl run_in_build_dir default
}

pkg_postinst() {
	xdg_pkg_postinst
	if has_version media-sound/mpd; then
		optfeature "to interface with MPD" dev-python/python-mpd2
	fi
}
