# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.102
	bzip2@0.6.1
	clap@4.6.1
	clap_builder@4.6.0
	clap_derive@4.6.1
	clap_lex@1.1.0
	colorchoice@1.0.5
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	either@1.15.0
	heck@0.5.0
	is_terminal_polyfill@1.70.2
	libbz2-rs-sys@0.2.3
	memchr@2.8.0
	once_cell_polyfill@1.70.2
	parse-wiki-text-2@0.2.0
	proc-macro2@1.0.106
	quick-xml@0.39.2
	quote@1.0.45
	rayon-core@1.13.0
	rayon@1.12.0
	strsim@0.11.1
	syn@2.0.117
	unicode-ident@1.0.24
	utf8parse@0.2.2
	windows-link@0.2.1
	windows-sys@0.61.2
"

RUST_MIN_VER="1.85.0"

inherit cargo

DESCRIPTION="Convert MediaWiki XML dumps into man(7) pages - so you can read Wikipedia in man"
HOMEPAGE="https://gitlab.com/vitaly_zdanevich_wikimedia/wiki2man_on_rust"
SRC_URI="
	https://gitlab.com/vitaly_zdanevich_wikimedia/wiki2man_on_rust/-/archive/${PV}/${P}.tar.bz2
	${CARGO_CRATE_URIS}
"

LICENSE="MIT Unicode-3.0 BZIP2"
SLOT="0"
KEYWORDS="~amd64"

QA_FLAGS_IGNORED="usr/bin/${PN}"

src_prepare() {
	default

	pushd "${ECARGO_VENDOR}/parse-wiki-text-2-0.2.0" >/dev/null || die
	eapply "${FILESDIR}/parse-wiki-text-2-0.2.0-utf8-boundaries.patch"
	popd >/dev/null || die
}
