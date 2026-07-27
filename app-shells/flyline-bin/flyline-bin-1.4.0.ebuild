# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Modern line editor for Bash"
HOMEPAGE="https://github.com/HalFrgrd/flyline"
SRC_URI="
	amd64? (
		https://github.com/HalFrgrd/flyline/releases/download/v${PV}/libflyline-v${PV}-x86_64-unknown-linux-gnu.tar.gz
			-> ${P}-amd64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	>=app-shells/bash-4.4:0[plugins]
	sys-devel/gcc:*
	sys-libs/glibc
"

RESTRICT="strip"

QA_PREBUILT="usr/lib*/bash/flyline"

src_install() {
	exeinto "/usr/$(get_libdir)/bash"
	newexe "libflyline.so.${PV}" flyline
}

pkg_postinst() {
	elog "Run 'enable flyline' in Bash to enable Flyline."
}
