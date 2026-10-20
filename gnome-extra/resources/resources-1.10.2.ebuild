# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	aho-corasick@1.1.4
	anstream@0.6.21
	anstyle-parse@0.2.7
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.13
	anyhow@1.0.102
	async-channel@2.5.0
	autocfg@1.5.0
	bitflags@2.11.0
	block@0.1.6
	bumpalo@3.20.2
	byteorder@1.5.0
	cairo-rs@0.21.5
	cairo-sys-rs@0.21.5
	cc@1.2.56
	cfg-expr@0.20.7
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	clap@4.5.60
	clap_builder@4.5.60
	clap_derive@4.5.55
	clap_lex@1.0.0
	colorchoice@1.0.4
	concurrent-queue@2.5.0
	const-random-macro@0.1.16
	const-random@0.1.18
	convert_case@0.6.0
	crossbeam-utils@0.8.21
	crunchy@0.2.4
	darling@0.20.11
	darling_core@0.20.11
	darling_macro@0.20.11
	diff@0.1.13
	dlv-list@0.5.2
	either@1.15.0
	env_logger@0.10.2
	equivalent@1.0.2
	errno-dragonfly@0.1.2
	errno@0.2.8
	event-listener-strategy@0.5.4
	event-listener@5.4.1
	field-offset@0.3.6
	find-msvc-tools@0.1.9
	fnv@1.0.7
	futures-channel@0.3.32
	futures-core@0.3.32
	futures-executor@0.3.32
	futures-io@0.3.32
	futures-macro@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	gdk-pixbuf-sys@0.21.5
	gdk-pixbuf@0.21.5
	gdk4-sys@0.10.3
	gdk4@0.10.3
	getrandom@0.2.17
	gettext-rs@0.7.7
	gettext-sys@0.26.0
	gio-sys@0.21.5
	gio@0.21.5
	glib-macros@0.21.5
	glib-sys@0.21.5
	glib@0.21.5
	glob@0.3.3
	gobject-sys@0.21.5
	graphene-rs@0.21.5
	graphene-sys@0.21.5
	gsk4-sys@0.10.3
	gsk4@0.10.3
	gtk4-macros@0.10.3
	gtk4-sys@0.10.3
	gtk4@0.10.3
	hashbrown@0.14.5
	hashbrown@0.16.1
	heck@0.5.0
	hermit-abi@0.5.2
	humantime@2.3.0
	ident_case@1.0.1
	indexmap@2.13.0
	is-terminal@0.4.17
	is_terminal_polyfill@1.70.2
	js-sys@0.3.91
	kernel32-sys@0.2.2
	kinded@0.3.0
	kinded_macros@0.3.0
	lazy-regex-proc_macros@3.6.0
	lazy-regex@3.6.0
	lazy_static@1.5.0
	libadwaita-sys@0.8.1
	libadwaita@0.8.1
	libc@0.2.182
	libloading@0.8.9
	locale_config@0.3.0
	log@0.4.29
	malloc_buf@0.0.6
	memchr@2.8.0
	memoffset@0.9.1
	neli-proc-macros@0.1.4
	neli-wifi@0.6.1
	neli@0.6.5
	nix@0.31.2
	num-traits@0.2.19
	num_cpus@1.17.0
	nutype@0.6.2
	nutype_macros@0.6.2
	nvml-wrapper-sys@0.9.0
	nvml-wrapper@0.12.0
	objc-foundation@0.1.1
	objc@0.2.7
	objc_id@0.1.1
	once_cell@1.21.3
	once_cell_polyfill@1.70.2
	ordered-multimap@0.7.3
	pango-sys@0.21.5
	pango@0.21.5
	parking@2.2.1
	pastey@0.2.1
	path-dedot@3.1.1
	pin-project-lite@0.2.17
	pkg-config@0.3.32
	plotters-backend@0.3.7
	plotters-cairo@0.8.0
	plotters@0.3.7
	pretty_assertions@1.4.1
	pretty_env_logger@0.5.0
	proc-macro-crate@3.5.0
	proc-macro2@1.0.106
	quote@1.0.45
	regex-automata@0.4.14
	regex-syntax@0.8.10
	regex@1.12.3
	rmp-serde@1.3.1
	rmp@0.8.15
	ron@0.12.0
	rust-ini@0.21.3
	rustc_version@0.4.1
	rustversion@1.0.22
	semver@1.0.27
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_spanned@1.0.4
	shlex@1.3.0
	slab@0.4.12
	smallvec@1.15.1
	static_assertions@1.1.0
	strsim@0.11.1
	strum@0.28.0
	strum_macros@0.28.0
	syn@1.0.109
	syn@2.0.117
	sysconf@0.3.4
	system-deps@7.0.7
	target-lexicon@0.13.3
	temp-dir@0.1.16
	termcolor@1.4.1
	thiserror-impl@1.0.69
	thiserror-impl@2.0.18
	thiserror@1.0.69
	thiserror@2.0.18
	tiny-keccak@2.0.2
	toml@0.9.12+spec-1.1.0
	toml_datetime@0.7.5+spec-1.1.0
	toml_datetime@1.0.0+spec-1.1.0
	toml_edit@0.25.4+spec-1.1.0
	toml_parser@1.0.9+spec-1.1.0
	toml_writer@1.0.6+spec-1.1.0
	typeid@1.0.3
	unescape@0.1.0
	unicode-ident@1.0.24
	unicode-segmentation@1.12.0
	urlencoding@2.1.3
	utf8parse@0.2.2
	uzers@0.12.2
	version-compare@0.2.1
	wasi@0.11.1+wasi-snapshot-preview1
	wasm-bindgen-macro-support@0.2.114
	wasm-bindgen-macro@0.2.114
	wasm-bindgen-shared@0.2.114
	wasm-bindgen@0.2.114
	web-sys@0.3.91
	winapi-build@0.1.1
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.2.8
	winapi@0.3.9
	windows-link@0.2.1
	windows-sys@0.61.2
	winnow@0.7.15
	wrapcenum-derive@0.4.1
	yansi@1.0.1
"

inherit cargo gnome2-utils meson xdg

DESCRIPTION="Keep an eye on system resources"
HOMEPAGE="https://github.com/nokyan/resources"
SRC_URI="https://github.com/nokyan/resources/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" ${CARGO_CRATE_URIS}"

LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD CC0-1.0 ISC MIT
	Unicode-3.0
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RUST_MIN_VER="1.85.0"

RDEPEND="
	sys-auth/polkit
	dev-libs/glib
	gui-libs/gtk
	>=gui-libs/libadwaita-1.8.2
"
DEPEND="${RDEPEND}"

src_configure () {
	cargo_gen_config
	local emesonargs=("-Dprofile=default")
	meson_src_configure
	ln -s "${CARGO_HOME}" "${BUILD_DIR}/cargo" || die
}

src_compile () {
	export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
	export CARGO_PROFILE_RELEASE_DEBUG=2
	export CARGO_PROFILE_RELEASE_STRIP=false
	meson_src_compile
}

#src_test () {
	#default_src_test
#}

pkg_postinst () {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm () {
	xdg_pkg_postrm
	gnome2_schemas_update
}
