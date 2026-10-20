# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Repository list for Archlinux's binary package manager"
HOMEPAGE="https://archlinux.org/mirrorlist/"
# gitlab.archlinux.org is behind Anubis anti-bot protection. Most IPs fetch
# fine, but flagged datacenter/CI IPs get an HTML challenge instead of the
# file, so the Manifest check fails. Workaround: fetch this package via curl
# using /etc/portage/package.env -> an env file containing:
#   FETCHCOMMAND='curl -fsSL -o "${DISTDIR}/${FILE}" "${URI}"'
SRC_URI="https://gitlab.archlinux.org/archlinux/packaging/packages/${PN}/-/raw/${PV}-1/mirrorlist -> ${P}"
S="${WORKDIR}"

LICENSE="GPL-2+"
SLOT="0"

KEYWORDS="-* ~amd64"

src_unpack() {
	cp "${DISTDIR}/${P}" mirrorlist || die
}

src_install() {
	insinto etc/pacman.d
	doins mirrorlist
}

pkg_postinst() {
	elog
	elog "This package installs only a plain list of mirrors for sys-apps/pacman."
	elog "You will need to uncomment at least one mirror in /etc/pacman.d/mirrorlist"
	elog
}
