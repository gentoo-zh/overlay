# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Kimi Code CLI, Moonshot AI's command-line coding agent"
HOMEPAGE="https://github.com/MoonshotAI/kimi-code"

GITHUB_BASE="https://github.com/MoonshotAI/kimi-code/releases/download/@moonshot-ai/kimi-code@${PV}"
SRC_URI="
	amd64? ( ${GITHUB_BASE}/kimi-code-linux-x64.zip -> ${P}-amd64.zip )
	arm64? ( ${GITHUB_BASE}/kimi-code-linux-arm64.zip -> ${P}-arm64.zip )
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror strip"

BDEPEND="app-arch/unzip"

QA_PREBUILT="usr/bin/kimi"

src_install() {
	dobin kimi
}
