# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="aliyunpan cli client, support Webdav service, JavaScript plugin"
HOMEPAGE="https://github.com/tickstep/aliyunpan"

SRC_URI="https://github.com/tickstep/aliyunpan/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/aliyunpan/releases/download/v${PV}/${P}-vendor.tar.xz
"
LICENSE="Apache-2.0 BSD BSD-2 ISC MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~s390 ~x86"

src_compile() {
	ego build -o bin/${PN} -trimpath
}

src_test() {
	local skip_tests="TestGetQRCodeLoginUrl|TestGetQRCodeLoginResult"
	skip_tests+="|TestGetRefreshToken|TestParseRefreshToken"
	skip_tests+="|TestBoltUltraFiles|TestLocalSyncDb|TestLocalGet"
	skip_tests+="|TestSendEmail"

	# These require maintainer-local services or filesystem paths.
	ego test ./... -skip "^(${skip_tests})$"
}

src_install() {
	dobin bin/${PN}
}

pkg_postinst() {
	elog "if you see \"FATAL ERROR: config file error: config file permission denied\""
	elog "try \"mkdir ~/.aliyunpan\""
}
