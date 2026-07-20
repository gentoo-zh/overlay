# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
inherit meson optfeature python-single-r1 xdg

DESCRIPTION="Bubblewrap-based application sandbox with resource isolation"
HOMEPAGE="https://github.com/igo95862/bubblejail"
SRC_URI="https://github.com/igo95862/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-3+ MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/cattrs[${PYTHON_USEDEP}]
		dev-python/pyqt6[gui,widgets,${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
		dev-python/tomli-w[${PYTHON_USEDEP}]
	')
	>=sys-apps/bubblewrap-0.5.0
	sys-apps/xdg-dbus-proxy
	sys-libs/libseccomp
"
DEPEND="${PYTHON_DEPS}"
BDEPEND="
	app-text/scdoc
	$(python_gen_cond_dep '
		dev-python/jinja2[${PYTHON_USEDEP}]
	')
"

src_configure() {
	local emesonargs=(
		-Dman=true
		-Duse-vendored-python-lxns=enabled
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	python_fix_shebang "${ED}"/usr/bin "${ED}"/usr/$(get_libdir)/bubblejail
	python_optimize "${ED}"/usr/lib/bubblejail/python-packages
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "desktop entry registration" dev-util/desktop-file-utils
	optfeature "desktop notifications" x11-libs/libnotify
	optfeature "alternative network stack" app-containers/slirp4netns
}

pkg_postrm() {
	xdg_pkg_postrm
}
