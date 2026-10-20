# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature

DESCRIPTION="Dark Gtk3.20+ theme created using the awesome Nord color pallete"
HOMEPAGE="https://github.com/EliverLara/Nordic"
SRC_URI="https://github.com/EliverLara/Nordic/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/Nordic-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="+gtk2 +gtk3 +gtk4 kde xfce mate gnome-shell cinnamon"

src_prepare() {
	default

	if use kde; then
		cd kde || die
		mv -v ./aurorae{,.old} || die
		mkdir -pv ./aurorae/themes || die
		mv -v ./aurorae.old/Nordic ./aurorae/themes/Nordic || die
		mv -v ./colorschemes ./color-schemes || die
		mv -v ./kvantum ./Kvantum || die

		# remove broken symlinks
		for file in $(find -L ./folders -type l)
		do
			if [ ! -d $file ]; then
				rm $file
			fi
		done
		mv -v ./folders ./icons || die

		# requires media-gfx/inkscape & x11-apps/xcursorgen
		# to build from sources
		# GIMP with “X11 Mouse Cursor (XMC)” plugin
		# to trim the cursors
		# NOT trivial
		rm -rf ./cursors || die

		mv -v ./sddm{,.old} || die
		mkdir -pv ./sddm/themes || die
		mv -v ./sddm.old ./sddm/themes/Nordic || die
	fi
}

src_configure() { :; }

src_compile() { :; }

src_install() {
	insinto /usr/share/themes/Nordic-v40
	doins -r ./{assets,index.theme}
	use gtk2 && doins -r ./gtk-2.0
	use gtk3 && doins -r ./gtk-3.0
	use gtk4 && doins -r ./gtk-4.0

	use xfce && doins -r ./xfwm4
	use mate && doins -r ./metacity-1
	use gnome-shell && doins -r ./gnome-shell
	use cinnamon && doins -r ./cinnamon

	if use kde; then
		cd kde || die
		insinto "/usr/share"
		doins -r .
	fi
}

pkg_postinst() {
	use kde && optfeature "Kvantum theme support" x11-themes/kvantum
}
