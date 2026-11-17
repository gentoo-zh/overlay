# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"
URI_PREFIX="https://github.com/1jehuang/${MY_PN}/releases/download/v${PV}"

DESCRIPTION="Coding agent CLI for Claude, ChatGPT and other model providers (prebuilt binary)"
HOMEPAGE="https://github.com/1jehuang/jcode"
SRC_URI="
	amd64? ( ${URI_PREFIX}/${MY_PN}-linux-x86_64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( ${URI_PREFIX}/${MY_PN}-linux-aarch64.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 BlueOak-1.0.0
	Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 ISC MIT-0 MPL-2.0 Unicode-3.0
	Unicode-DFS-2016 Unlicense WTFPL-2 ZLIB
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	amd64? ( >=sys-libs/glibc-2.17 )
	arm64? (
		dev-libs/openssl:0/3
		>=sys-libs/glibc-2.39
	)
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	if use amd64; then
		newbin ${MY_PN}-linux-x86_64.bin ${MY_PN}
	else
		newbin ${MY_PN}-linux-aarch64 ${MY_PN}
	fi
}

pkg_postinst() {
	elog "jcode sends anonymous usage telemetry by default."
	elog "Run 'jcode telemetry disable' or set JCODE_NO_TELEMETRY=1 to turn it off."
}
