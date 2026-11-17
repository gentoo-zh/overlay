# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="print the IP addresses in a range"
HOMEPAGE="https://devel.ringlet.net/sysutils/prips/"
SRC_URI="https://devel.ringlet.net/files/sys/prips/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

src_compile() {
	emake -C c
}

src_install() {
	dobin c/prips
	doman prips.1
}
