# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# the codegen runs rustfmt on what it writes
RUST_REQ_USE="rustfmt"

inherit cargo

MY_PN=flutter_rust_bridge
MY_P=${MY_PN}-${PV}
DESCRIPTION="Binding generator between Flutter/Dart and Rust"
HOMEPAGE="https://github.com/fzyzcjy/flutter_rust_bridge"
SRC_URI="
	https://github.com/fzyzcjy/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${MY_P}.tar.gz
	https://github.com/gentoo-zh-drafts/${MY_PN}/releases/download/v${PV}/${MY_P}-crates.tar.xz
"
S="${WORKDIR}/${MY_P}/frb_codegen"

LICENSE="MIT"
# Dependent crate licenses of frb_codegen alone; the crate tarball covers the
# whole workspace, but only this member is built
LICENSE+=" 0BSD Apache-2.0 BSD MIT MPL-2.0 Unicode-DFS-2016"
SLOT="0"
KEYWORDS="~amd64"

# it runs rustfmt on the Rust it writes and ffigen through dart; ffigen loads
# the libclang of the slot the consumer passes as --llvm-path, and the
# consumer brings the Dart SDK and a pub cache with ffigen
DEPEND="${RUST_DEPEND}"
RDEPEND="${DEPEND}
	llvm-core/clang:*
"

QA_FLAGS_IGNORED="usr/bin/${MY_PN}_codegen"

src_test() {
	# the two tests in main.rs generate and build the example crates with
	# dart and cargo, online
	cargo_src_test --lib
}
