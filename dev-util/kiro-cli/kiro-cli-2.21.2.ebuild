# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

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

src_compile() {
	# Completions are not shipped in the tarball; generate them from the binary.
	local sh
	for sh in bash zsh fish; do
		./bin/kiro-cli completion "${sh}" > "kiro-cli.${sh}" || die
	done
}

src_install() {
	# The bundled self-updater refuses to run for binaries outside
	# ~/.local/bin and defers uninstall to the package manager, so a
	# system install under /usr/bin is not self-updated.
	dobin bin/kiro-cli bin/kiro-cli-chat bin/kiro-cli-term

	newbashcomp kiro-cli.bash kiro-cli
	newzshcomp kiro-cli.zsh _kiro-cli
	newfishcomp kiro-cli.fish kiro-cli.fish
}
