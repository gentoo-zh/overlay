# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ZIG_SLOT="0.16"
inherit zig

DESCRIPTION="Command-line tool for switching Codex accounts"
HOMEPAGE="https://github.com/Loongphy/codex-auth"
SRC_URI="https://github.com/Loongphy/codex-auth/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=net-libs/nodejs-22
"

DOCS=( README.md docs )

src_test() {
	ezig test src/main.zig -lc
}
