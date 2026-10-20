# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit gnome2-utils

EXTENSION_VERSION="69"

DESCRIPTION="The most popular clipboard manager for GNOME, with over 1M downloads"
HOMEPAGE="https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator"
SRC_URI="https://extensions.gnome.org/extension-data/clipboard-indicatortudmotu.com.v${EXTENSION_VERSION}.shell-extension.zip -> ${P}.zip"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-libs/glib:2
	app-eselect/eselect-gnome-shell-extensions
	>=gnome-base/gnome-shell-${PV%.*}
"

BDEPEND="
	app-arch/unzip
"

extension_uuid="clipboard-indicator@tudmotu.com"

src_install() {
	gnome2_schemas_savelist
	insinto /usr/share/gnome-shell/extensions/${extension_uuid}
	doins -r *
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}

pkg_postrm() {
	gnome2_schemas_update
}
