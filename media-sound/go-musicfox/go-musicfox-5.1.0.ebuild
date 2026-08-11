# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module optfeature

DESCRIPTION="Command-line Netease Cloud Music written in Go"
HOMEPAGE="https://github.com/go-musicfox/go-musicfox"
SRC_URI="https://github.com/go-musicfox/go-musicfox/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0 BSD BSD-2 GPL-3 LGPL-3-with-linking-exception MIT"
SLOT="0"
KEYWORDS="~amd64 ~loong"
IUSE="clang"

DEPEND="
	media-libs/flac
	media-libs/alsa-lib
"
RDEPEND="${DEPEND}"
BDEPEND="
	${DEPEND}
	>=dev-lang/go-1.26.0
	|| (
		llvm-core/clang
		sys-devel/gcc[objc]
	)
	clang? ( llvm-core/clang )
"

src_compile() {
	if use clang; then
		ego env -w "CC=clang"
		ego env -w "CXX=clang++"
	fi
	local -x GIT_TAG="v${PV}" GIT_REVISION="v${PV}"
	emake LDFLAGS= build
}

src_test() {
	# The randomized integration test intermittently reports no next song.
	ego test ./internal/... ./utils/... -skip '^TestPlaylistManagerWithUIInteraction$'
}

src_install() {
	dobin bin/musicfox
}

pkg_postinst() {
	optfeature "WebView login" net-libs/webkit-gtk:6 net-libs/webkit-gtk:4.1
}
