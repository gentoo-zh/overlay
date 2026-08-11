# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Command-line Netease Cloud Music written in Go"
HOMEPAGE="https://github.com/go-musicfox/go-musicfox"
SRC_URI="https://github.com/go-musicfox/go-musicfox/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~loong"
IUSE="clang"

DEPEND="
	media-libs/flac
	media-libs/alsa-lib
	>=dev-lang/go-1.26.0
"
RDEPEND="${DEPEND}"
BDEPEND="
	${DEPEND}
	|| (
		llvm-core/clang
		sys-devel/gcc[objc]
	)
	clang? ( llvm-core/clang )
"

QA_PRESTRIPPED="/usr/bin/musicfox"

src_compile() {
	if use clang; then
		ego env -w "CC=clang"
		ego env -w "CXX=clang++"
	fi
	local -x GIT_TAG="v${PV}" GIT_REVISION="v${PV}"
	emake build
}

src_install() {
	dobin bin/musicfox
}
