# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

MY_PN="rest-server"
DESCRIPTION="A high performance HTTP server that implements restic's REST backend API"
HOMEPAGE="https://github.com/restic/rest-server"
SRC_URI="
	https://github.com/restic/rest-server/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/rest-server/releases/download/v${PV}/${MY_PN}-${PV}-vendor.tar.xz
		-> ${P}-vendor.golang-dist-mirror-action.tar.xz
"

S="${WORKDIR}/${MY_PN}-${PV}"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
QA_PRESTRIPPED="/usr/bin/${PN}"

src_compile() {
	ego run build.go
}

src_install() {
	newbin ${MY_PN} ${PN}
}
