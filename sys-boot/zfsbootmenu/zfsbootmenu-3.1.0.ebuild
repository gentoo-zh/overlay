# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit prefix

DESCRIPTION="ZFS bootloader for root-on-ZFS systems"
HOMEPAGE="https://zfsbootmenu.org"
SRC_URI="https://github.com/zbm-dev/zfsbootmenu/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	app-shells/fzf
	dev-lang/perl
	dev-perl/boolean
	dev-perl/Sort-Versions
	dev-perl/YAML-PP
	sys-apps/kexec-tools
	sys-block/mbuffer
	sys-fs/zfs
	sys-kernel/dracut
"

src_prepare() {
	default
	hprefixify bin/*
	if [[ -n ${BROOT} ]]; then
		sed -e "s,#!/bin/sh,#!${BROOT}/bin/sh," \
			-i install-tree.sh releng/version.sh || die
	fi
}

src_compile() {
	:
}

src_install() {
	emake \
		DESTDIR="${ED}" \
		EXAMPLES="/usr/share/doc/${PF}/examples" \
		install

	dodoc README.md
	fperms 0644 \
		"/usr/share/doc/${PF}/examples/hooks/README.md" \
		"/usr/share/doc/${PF}/examples/refind_linux.conf" \
		"/usr/share/doc/${PF}/examples/syslinux.cfg"
	docompress -x "/usr/share/doc/${PF}/examples"
}

pkg_postinst() {
	elog "See the Gentoo ZFSBootMenu guide for bootloader configuration:"
	elog "https://wiki.gentoo.org/wiki/ZFS/ZFSBootMenu"
}
