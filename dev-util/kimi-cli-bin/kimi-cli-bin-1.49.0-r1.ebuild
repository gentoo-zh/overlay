# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="kimi"

DESCRIPTION="Kimi Code CLI - an agentic coding tool by Moonshot AI"
HOMEPAGE="https://github.com/MoonshotAI/kimi-cli"
URLPREFIX="https://github.com/MoonshotAI/kimi-cli/releases/download"
SRC_URI="
	amd64? (
		${URLPREFIX}/${PV}/${MY_PN}-${PV}-x86_64-unknown-linux-gnu.tar.gz
			-> ${P}-x86_64-unknown-linux-gnu.tar.gz
	)
	arm64? (
		${URLPREFIX}/${PV}/${MY_PN}-${PV}-aarch64-unknown-linux-gnu.tar.gz
			-> ${P}-aarch64-unknown-linux-gnu.tar.gz
	)
"

S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="strip"

RDEPEND="
	sys-libs/glibc
	virtual/zlib
"

src_install() {
	dobin kimi
}
