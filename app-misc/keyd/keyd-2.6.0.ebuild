# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="A key remapping daemon for linux"
HOMEPAGE="https://github.com/rvaiya/keyd"
SRC_URI="https://github.com/rvaiya/keyd/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
DEPEND="acct-group/keyd"
RDEPEND="$DEPEND"

src_prepare() {
	sed -i "/-groupadd keyd/d" Makefile || die
	default
}

src_install() {
	dobin bin/keyd
	dobin bin/keyd-application-mapper

	sed -e 's#@PREFIX@#/usr#' keyd.service.in > keyd.service || die
	systemd_dounit keyd.service

	# sysusers.d taken cared by acct-group/keyd already
	rm data/sysusers.d || die
	insinto /usr/share/keyd
	doins -r data

	dodoc docs/{CHANGELOG.md,DESIGN.md}
	dodoc README.md
	dodoc -r examples

	insinto /etc/keyd
	doins "${FILESDIR}"/default.conf
	gzip -d data/{keyd,keyd-application-mapper}.1.gz || die
	doman data/{keyd,keyd-application-mapper}.1
}
