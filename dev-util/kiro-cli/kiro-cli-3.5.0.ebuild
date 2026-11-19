# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Kiro CLI, Amazon's agentic coding assistant for the terminal (prebuilt binary)"
HOMEPAGE="https://kiro.dev/cli/"
SRC_URI="
	amd64? (
		https://prod.download.cli.kiro.dev/stable/${PV}/kirocli-x86_64-linux.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://prod.download.cli.kiro.dev/stable/${PV}/kirocli-aarch64-linux.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}/kirocli"

LICENSE="Kiro"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="sys-libs/glibc"

QA_PREBUILT="*"

src_install() {
	# The bundled self-updater refuses to run for binaries outside
	# ~/.local/bin and defers uninstall to the package manager, so a
	# system install under /usr/bin is not self-updated.
	dobin bin/kiro-cli
}
