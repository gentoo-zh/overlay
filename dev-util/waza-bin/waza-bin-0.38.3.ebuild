# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="CLI and framework for AI agent skills"
HOMEPAGE="https://github.com/microsoft/waza"
SRC_URI="
	amd64? ( https://github.com/microsoft/waza/releases/download/v${PV}/waza-linux-amd64 -> ${P}-amd64 )
	arm64? ( https://github.com/microsoft/waza/releases/download/v${PV}/waza-linux-arm64 -> ${P}-arm64 )
"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="mirror strip"
QA_PREBUILT="usr/bin/waza"

src_install() {
	newbin "${DISTDIR}/${A}" waza
}
