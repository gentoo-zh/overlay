# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

RUST_MIN_VER="1.97.0"

inherit cargo wrapper

DESCRIPTION="Fast, disk space efficient package manager"
HOMEPAGE="https://pnpm.io"
SRC_URI="
	https://github.com/pnpm/pnpm/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/pnpm/releases/download/v${PV}/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions Boost-1.0 BSD-1 BSD-2 BSD
	CC0-1.0 CDLA-Permissive-2.0 GPL-2 ISC LGPL-2.1+ MIT MIT-0 MPL-2.0
	Unicode-3.0 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="net-libs/nodejs"

src_compile() {
	cargo_src_compile -p pnpm-cli
}

src_install() {
	# The workspace root is a virtual manifest and cargo install takes no -p.
	cargo_src_install --path pnpm/crates/cli

	# The executable resolves its own path, so an alias cannot be a symlink.
	make_wrapper pn pnpm
	make_wrapper pnpx "pnpm dlx"
	make_wrapper pnx "pnpm dlx"
}
