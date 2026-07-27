# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="GnuPG keyring of Archlinux developer keys"
HOMEPAGE="https://gitlab.archlinux.org/archlinux/archlinux-keyring"
# gitlab.archlinux.org is behind Anubis anti-bot protection. Most IPs fetch
# fine, but flagged datacenter/CI IPs get an HTML challenge instead of the
# file, so the Manifest check fails. Workaround: fetch this package via curl
# using /etc/portage/package.env -> an env file containing:
#   FETCHCOMMAND='curl -fsSL -o "${DISTDIR}/${FILE}" "${URI}"'
#SRC_URI="https://sources.archlinux.org/other/${PN}/${P}.tar.gz"
SRC_URI="https://gitlab.archlinux.org/archlinux/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="GPL-2" # "GPL" for the Arch linux package
SLOT="0"

KEYWORDS="~amd64"

BDEPEND=">=app-crypt/sequoia-sq-0.33.0"

src_compile(){
	emake build
}

src_install(){
	# Upstream resolves the systemd unit dir via "pkgconf --variable
	# systemd_system_unit_dir systemd", which is empty on systems without
	# systemd (e.g. OpenRC profiles) and makes the wkd-sync .service/.timer
	# install into "/". Pin it explicitly so it always lands in the right path.
	emake \
		PREFIX='/usr' \
		DESTDIR="${D}" \
		SYSTEMD_SYSTEM_UNIT_DIR="$(systemd_get_systemunitdir)" \
		install
}

pkg_postinst() {
	einfo ""
	einfo "This package only installs the keyring files while sys-apps/pacman"
	einfo "initializes these keyrings to actually use it. This is a different"
	einfo "behaviour from Archlinux, but is necessary to avoid circular deps."
	einfo ""
}
