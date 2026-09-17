# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion toolchain-funcs

DESCRIPTION="Git worktree management for parallel AI agent workflows (prebuilt binary)"
HOMEPAGE="https://worktrunk.dev https://github.com/max-sixty/worktrunk"
SRC_URI="
	amd64? ( https://github.com/max-sixty/worktrunk/releases/download/v${PV}/worktrunk-x86_64-unknown-linux-musl.tar.xz
		-> ${P}-amd64.tar.xz )
	arm64? ( https://github.com/max-sixty/worktrunk/releases/download/v${PV}/worktrunk-aarch64-unknown-linux-musl.tar.xz
		-> ${P}-arm64.tar.xz )
"

LICENSE="|| ( Apache-2.0 MIT )"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

# https://github.com/max-sixty/worktrunk/blob/v0.76.0/src/git/version.rs#L31
RDEPEND=">=dev-vcs/git-2.43.0"

QA_PREBUILT="usr/bin/wt usr/bin/git-wt"

src_unpack() {
	default
	mv "${WORKDIR}"/worktrunk-*-unknown-linux-musl "${S}" || die
}

src_install() {
	dobin wt git-wt
	dodoc README.md CHANGELOG.md LICENSE

	if ! tc-is-cross-compiler; then
		local cmd
		for cmd in wt git-wt; do
			./${cmd} config shell completions bash > "${T}/${cmd}" || die
			./${cmd} config shell completions fish > "${T}/${cmd}.fish" || die
			./${cmd} config shell completions zsh > "${T}/_${cmd}" || die
			dobashcomp "${T}/${cmd}"
			dofishcomp "${T}/${cmd}.fish"
			dozshcomp "${T}/_${cmd}"
		done
	fi
}

pkg_postinst() {
	elog "To enable shell integration and automatic directory switching, run:"
	elog "  wt config shell install"
	elog "Then restart or reload your shell."
}
