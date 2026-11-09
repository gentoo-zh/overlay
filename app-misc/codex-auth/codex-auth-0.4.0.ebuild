# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ZIG_SLOT="0.17"
inherit zig

DESCRIPTION="Command-line tool for switching Codex accounts"
HOMEPAGE="https://github.com/Loongphy/codex-auth"
SRC_URI="https://github.com/Loongphy/codex-auth/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=net-libs/nodejs-22
"

DOCS=( README.md docs )

src_configure() {
	local my_zbs_args=(
		-Dstrip=false
	)

	zig_src_configure
}

src_test() {
	# cli_integration_test and tui_pty_test run the CLI and test helpers from
	# -Dcli-prefix, while zig_src_test would move their own install under DESTDIR
	zig_src_compile test-helpers
	# ezig sets CLICOLOR_FORCE, which colours the warnings the tests compare
	local -x NO_COLOR=1
	# writeAccountsTable truncates to the terminal width when stdout is a tty
	zig_src_test -Dcli-prefix="${BUILD_DIR}/usr" > >(cat)
}
