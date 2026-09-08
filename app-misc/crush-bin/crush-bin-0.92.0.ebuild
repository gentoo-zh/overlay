# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="AI coding agent for your terminal (prebuilt binary)"
HOMEPAGE="https://github.com/charmbracelet/crush"
BASE_URI="https://github.com/charmbracelet/crush/releases/download/v${PV}/crush_${PV}"
SRC_URI="
	amd64? ( ${BASE_URI}_Linux_x86_64.tar.gz )
	arm64? ( ${BASE_URI}_Linux_arm64.tar.gz )
"

LICENSE="FSL-1.1-MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="!app-misc/crush"

QA_PREBUILT="usr/bin/crush"

src_unpack() {
	default
	mv "${WORKDIR}"/crush_${PV}_Linux_* "${S}" || die
}

src_prepare() {
	default
	gzip -d manpages/crush.1.gz || die
}

src_install() {
	dobin crush
	dodoc README.md LICENSE.md
	doman manpages/crush.1

	newbashcomp completions/crush.bash crush
	dofishcomp completions/crush.fish
	newzshcomp completions/crush.zsh _crush
}
