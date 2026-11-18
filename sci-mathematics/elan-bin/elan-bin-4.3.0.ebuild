# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion toolchain-funcs

DESCRIPTION="Lean version manager (prebuilt binary)"
HOMEPAGE="https://github.com/leanprover/elan"
SRC_URI="
	amd64? ( https://github.com/leanprover/elan/releases/download/v${PV}/elan-x86_64-unknown-linux-gnu.tar.gz
		-> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/leanprover/elan/releases/download/v${PV}/elan-aarch64-unknown-linux-gnu.tar.gz
		-> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="|| ( Apache-2.0 MIT )"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD Boost-1.0 MIT Unicode-3.0 Unicode-DFS-2016"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	!sci-mathematics/lean
	app-misc/ca-certificates
"

QA_PREBUILT="usr/bin/elan"

src_install() {
	local proxy

	newbin elan-init elan
	for proxy in lean leanpkg leanchecker leanc leanmake lake; do
		dosym -r /usr/bin/elan "/usr/bin/${proxy}"
	done

	if ! tc-is-cross-compiler; then
		"${ED}/usr/bin/elan" completions bash > "${T}/elan" || die
		"${ED}/usr/bin/elan" completions fish > "${T}/elan.fish" || die
		"${ED}/usr/bin/elan" completions zsh > "${T}/_elan" || die
		dobashcomp "${T}/elan"
		dofishcomp "${T}/elan.fish"
		dozshcomp "${T}/_elan"
	fi
}
