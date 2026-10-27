# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler@1.0.2
	aho-corasick@1.1.2
	anyhow@1.0.75
	approx@0.5.1
	assert_cmd@1.0.8
	atty@0.2.14
	autocfg@0.1.8
	autocfg@1.1.0
	bincode@1.3.3
	bio-types@1.0.1
	bio@1.4.0
	bit-set@0.5.3
	bit-vec@0.6.3
	bitflags@1.3.2
	bstr@0.2.17
	buffer-redux@1.0.0
	bv@0.11.1
	bytecount@0.6.4
	bytemuck@1.14.0
	byteorder@1.5.0
	bzip2-sys@0.1.11+1.0.8
	bzip2@0.4.4
	cc@1.0.83
	cfg-if@0.1.10
	cfg-if@1.0.0
	clap@3.2.25
	clap_derive@3.2.25
	clap_lex@0.2.4
	cloudabi@0.0.3
	crc32fast@1.3.2
	crossbeam-deque@0.8.3
	crossbeam-epoch@0.9.15
	crossbeam-utils@0.8.16
	csv-core@0.1.11
	csv@1.3.0
	custom_derive@0.1.7
	dashmap@5.5.3
	derive-new@0.5.9
	difference@2.0.0
	difflib@0.4.0
	doc-comment@0.3.3
	editdistancek@1.0.2
	either@1.9.0
	enum-map-derive@0.6.0
	enum-map@1.1.1
	equivalent@1.0.1
	fastrand@1.9.0
	feature-probe@0.1.1
	fixedbitset@0.4.2
	flate2@1.0.27
	float-cmp@0.8.0
	fuchsia-cprng@0.1.1
	futures-channel@0.3.28
	futures-core@0.3.28
	futures-executor@0.3.28
	futures-io@0.3.28
	futures-sink@0.3.28
	futures-task@0.3.28
	futures-util@0.3.28
	futures@0.3.28
	fxhash@0.2.1
	gbdt@0.1.1
	gcollections@1.5.0
	getrandom@0.2.10
	getset@0.1.2
	hashbrown@0.12.3
	hashbrown@0.14.1
	heck@0.4.1
	hermit-abi@0.1.19
	indexed@0.1.1
	indexmap@1.9.3
	indexmap@2.0.2
	instant@0.1.12
	intervallum@1.4.0
	itertools-num@0.1.3
	itertools@0.10.5
	itertools@0.11.0
	itoa@1.0.9
	lazy_static@1.4.0
	libc@0.2.174
	libm@0.2.8
	lock_api@0.4.10
	log@0.4.20
	lzma-sys@0.1.20
	matrixmultiply@0.3.8
	memchr@2.6.4
	memmap2@0.9.7
	memoffset@0.9.0
	miniz_oxide@0.7.1
	multimap@0.8.3
	nalgebra-macros@0.1.0
	nalgebra@0.29.0
	ndarray@0.15.6
	needletail@0.5.1
	newtype_derive@0.1.6
	normalize-line-endings@0.3.0
	num-complex@0.4.4
	num-integer@0.1.45
	num-rational@0.4.1
	num-traits@0.2.17
	once_cell@1.18.0
	ordered-float@3.9.1
	os_str_bytes@6.5.1
	parking_lot@0.12.1
	parking_lot_core@0.9.8
	paste@1.0.14
	petgraph@0.6.4
	pin-project-lite@0.2.13
	pin-utils@0.1.0
	pkg-config@0.3.27
	ppv-lite86@0.2.17
	predicates-core@1.0.6
	predicates-tree@1.0.9
	predicates@1.0.8
	predicates@2.1.5
	proc-macro-error-attr@1.0.4
	proc-macro-error@1.0.4
	proc-macro2@0.2.3
	proc-macro2@1.0.69
	quote@0.4.2
	quote@1.0.33
	rand@0.6.5
	rand@0.8.5
	rand_chacha@0.1.1
	rand_chacha@0.3.1
	rand_core@0.3.1
	rand_core@0.4.2
	rand_core@0.6.4
	rand_distr@0.4.3
	rand_hc@0.1.0
	rand_isaac@0.1.1
	rand_jitter@0.1.4
	rand_os@0.1.3
	rand_pcg@0.1.2
	rand_xorshift@0.1.1
	rawpointer@0.2.1
	rayon-core@1.12.0
	rayon@1.8.0
	rdrand@0.4.0
	redox_syscall@0.1.57
	redox_syscall@0.3.5
	reflection@0.1.3
	reflection_derive@0.1.1
	regex-automata@0.1.10
	regex-automata@0.4.1
	regex-syntax@0.8.0
	regex@1.10.0
	rust-lapper@1.1.0
	rustc_version@0.1.7
	rustversion@1.0.14
	ryu@1.0.15
	safe_arch@0.7.1
	safemem@0.3.3
	scopeguard@1.2.0
	semver@0.1.20
	serde@1.0.188
	serde_derive@1.0.188
	serde_derive_internals@0.21.0
	serde_json@1.0.107
	serial_test@0.10.0
	serial_test_derive@0.10.0
	simba@0.6.0
	simple-logging@2.0.2
	slab@0.4.9
	smallvec@1.15.1
	statrs@0.16.0
	strsim@0.10.0
	strum@0.25.0
	strum_macros@0.25.2
	syn@0.12.15
	syn@1.0.109
	syn@2.0.38
	termcolor@1.3.0
	termtree@0.4.1
	textwrap@0.16.0
	thiserror-impl@1.0.49
	thiserror@1.0.49
	thread-id@3.3.0
	tikv-jemalloc-sys@0.5.4+5.3.0-patched
	tikv-jemallocator@0.5.4
	trees@0.2.1
	trilean@1.1.0
	triple_accel@0.4.0
	tsv@0.1.1
	typenum@1.17.0
	unicode-ident@1.0.12
	unicode-xid@0.1.0
	vec_map@0.8.2
	version_check@0.9.4
	wait-timeout@0.2.0
	wasi@0.11.0+wasi-snapshot-preview1
	wide@0.7.12
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.6
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-targets@0.48.5
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_msvc@0.48.5
	windows_i686_gnu@0.48.5
	windows_i686_msvc@0.48.5
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_msvc@0.48.5
	xz2@0.1.7
"

inherit cargo

DESCRIPTION="Fast, robust ANI and aligned fraction for metagenomic genomes and contigs"
HOMEPAGE="https://github.com/bluenote-1577/skani"
SRC_URI="
	https://github.com/bluenote-1577/skani/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="|| ( Apache-2.0 MIT )"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD-2 BSD ISC MIT Unicode-DFS-2016"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	app-arch/bzip2:=
	app-arch/xz-utils
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	sed -e '/^lto = /d' -i Cargo.toml || die
	find "${ECARGO_VENDOR}"/{bzip2,lzma}-sys-* -name '*.c' -delete || die
}

src_configure() {
	# https://wiki.gentoo.org/wiki/Project:Rust/sys_crates#bzip2-sys
	mkdir "${T}/pkg-config" || die
	export PKG_CONFIG_PATH=${T}/pkg-config${PKG_CONFIG_PATH+:${PKG_CONFIG_PATH}}
	cat >> "${T}/pkg-config/bzip2.pc" <<-EOF || die
		Name: bzip2
		Version: 9999
		Description:
		Libs: -lbz2
	EOF

	cargo_src_configure
}
