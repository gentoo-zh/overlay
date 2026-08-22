# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="BaiduPCS-Go"

inherit go-module

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/qjfoidnh/${MY_PN}.git"
	src_unpack() {
		git-r3_src_unpack
	}
else
	SRC_URI="https://github.com/qjfoidnh/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/gentoo-zh-drafts/${MY_PN}/releases/download/v${PV}/${MY_PN}-${PV}-vendor.tar.xz
			-> ${P}-vendor.tar.xz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${MY_PN}-${PV}"
fi

DESCRIPTION="Terminal utility for Baidu Network Disk (Golang Version)"
HOMEPAGE="https://github.com/qjfoidnh/BaiduPCS-Go"

LICENSE="Apache-2.0"
SLOT="0"

src_compile() {
	ego build -o ${PN}
}

src_install() {
	dobin ${PN}
}
