# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler2@2.0.1
	android_system_properties@0.1.5
	anyhow@1.0.103
	async-broadcast@0.7.2
	async-channel@2.5.0
	async-executor@1.14.0
	async-io@2.6.0
	async-lock@3.4.2
	async-process@2.5.0
	async-recursion@1.1.1
	async-signal@0.2.14
	async-task@4.7.1
	async-trait@0.1.89
	atomic-waker@1.1.2
	atspi-common@0.13.0
	atspi-connection@0.13.0
	atspi-proxies@0.13.0
	atspi@0.29.0
	autocfg@1.5.0
	base64@0.22.1
	bitflags@2.11.1
	bitvec@1.0.1
	block-buffer@0.12.1
	blocking@1.6.2
	bumpalo@3.20.2
	bytemuck@1.25.0
	byteorder-lite@0.1.0
	bytes@1.11.1
	cc@1.2.62
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	chrono@0.4.44
	concurrent-queue@2.5.0
	const-oid@0.10.2
	core-foundation-sys@0.8.7
	cosmic-protocols@0.2.0
	cpufeatures@0.3.0
	crc32fast@1.5.0
	crossbeam-utils@0.8.21
	crypto-common@0.2.2
	darling@0.23.0
	darling_core@0.23.0
	darling_macro@0.23.0
	digest@0.11.3
	downcast-rs@1.2.1
	dyn-clone@1.0.20
	endi@1.1.1
	enumflags2@0.7.12
	enumflags2_derive@0.7.12
	equivalent@1.0.2
	errno@0.3.14
	evdev@0.13.2
	event-listener-strategy@0.5.4
	event-listener@5.4.2
	fastrand@2.4.1
	fdeflate@0.3.7
	find-msvc-tools@0.1.9
	flate2@1.1.9
	foldhash@0.1.5
	funty@2.0.0
	futures-channel@0.3.32
	futures-core@0.3.32
	futures-executor@0.3.32
	futures-io@0.3.32
	futures-lite@2.6.1
	futures-macro@0.3.32
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	futures@0.3.32
	getrandom@0.4.2
	hashbrown@0.15.5
	hashbrown@0.17.1
	heck@0.5.0
	hermit-abi@0.5.2
	hex@0.4.3
	hybrid-array@0.4.14
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	id-arena@2.3.0
	ident_case@1.0.1
	image@0.25.10
	indexmap@2.14.0
	itoa@1.0.18
	js-sys@0.3.98
	leb128fmt@0.1.0
	libc@0.2.186
	libmimalloc-sys@0.1.49
	linux-raw-sys@0.12.1
	log@0.4.29
	memchr@2.8.0
	memoffset@0.9.1
	mimalloc@0.1.52
	miniz_oxide@0.8.9
	mio@1.2.0
	moxcms@0.8.1
	nix@0.29.0
	num-traits@0.2.19
	once_cell@1.21.4
	ordered-stream@0.2.0
	parking@2.2.1
	pastey@0.2.2
	pin-project-lite@0.2.17
	piper@0.2.5
	pkg-config@0.3.33
	png@0.18.1
	polling@3.11.0
	prettyplease@0.2.37
	proc-macro-crate@3.5.0
	proc-macro2@1.0.106
	pxfm@0.1.29
	quick-xml@0.39.4
	quote@1.0.45
	r-efi@6.0.0
	radium@0.7.0
	ref-cast-impl@1.0.25
	ref-cast@1.0.25
	rmcp-macros@1.7.0
	rmcp@1.7.0
	rustix@1.1.4
	rustversion@1.0.22
	schemars@1.2.1
	schemars_derive@1.2.1
	semver@1.0.28
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_derive_internals@0.29.1
	serde_json@1.0.149
	serde_repr@0.1.20
	sha2@0.11.0
	shlex@1.3.0
	signal-hook-registry@1.4.8
	simd-adler32@0.3.9
	slab@0.4.12
	smallvec@1.15.1
	socket2@0.6.3
	static_assertions@1.1.0
	strsim@0.11.1
	syn@2.0.117
	tap@1.0.1
	tempfile@3.27.0
	thiserror-impl@2.0.18
	thiserror@2.0.18
	tokio-macros@2.7.0
	tokio-util@0.7.18
	tokio@1.52.3
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.11+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing@0.1.44
	typenum@1.20.1
	uds_windows@1.2.1
	unicode-ident@1.0.24
	unicode-xid@0.2.6
	uuid@1.23.1
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.3+wasi-0.2.9
	wasip3@0.4.0+wasi-0.3.0-rc-2026-01-06
	wasm-bindgen-macro-support@0.2.121
	wasm-bindgen-macro@0.2.121
	wasm-bindgen-shared@0.2.121
	wasm-bindgen@0.2.121
	wasm-encoder@0.244.0
	wasm-metadata@0.244.0
	wasmparser@0.244.0
	wayland-backend@0.3.15
	wayland-client@0.31.14
	wayland-protocols-wlr@0.3.12
	wayland-protocols@0.32.12
	wayland-scanner@0.31.10
	wayland-sys@0.31.11
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.61.2
	winnow@1.0.2
	wit-bindgen-core@0.51.0
	wit-bindgen-rust-macro@0.51.0
	wit-bindgen-rust@0.51.0
	wit-bindgen@0.51.0
	wit-bindgen@0.57.1
	wit-component@0.244.0
	wit-parser@0.244.0
	wyz@0.5.1
	xkeysym@0.2.1
	zbus-lockstep-macros@0.5.2
	zbus-lockstep@0.5.2
	zbus@5.15.0
	zbus_macros@5.15.0
	zbus_names@4.3.2
	zbus_xml@5.1.1
	zmij@1.0.21
	zune-core@0.5.1
	zune-jpeg@0.5.15
	zvariant@5.11.0
	zvariant_derive@5.11.0
	zvariant_utils@3.3.1
"

# Highest rust-version among dependency crates: darling 0.23.0, image 0.25.10 (1.88.0)
RUST_MIN_VER="1.88.0"

inherit cargo optfeature

DESCRIPTION="MCP server for agent control of a Linux desktop"
HOMEPAGE="https://github.com/agent-sh/computer-use-linux"
SRC_URI="
	https://github.com/agent-sh/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" Apache-2.0 GPL-3 MIT Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64"

# Provides the AT-SPI registry the accessibility tree reads.
RDEPEND="app-accessibility/at-spi2-core"

src_install() {
	cargo_src_install
	insinto /usr/share/${PN}
	doins -r skills
}

pkg_postinst() {
	optfeature "keyboard and pointer input on X11" x11-misc/xdotool
	optfeature "window management on X11" x11-misc/wmctrl x11-apps/xprop
	optfeature "input synthesis through uinput on Wayland" x11-misc/ydotool
	optfeature "enabling the accessibility setting through gsettings" dev-libs/glib
	optfeature "completion notifications" x11-libs/libnotify
}

src_test() {
	# These bind Unix sockets under a temp dir whose name exceeds sun_path
	# when TMPDIR is as long as portage's.
	local CARGO_SKIP_TESTS=(
		diagnostics_impl::tests::ydotool_socket_check_accepts_datagram_socket
		windowing::backends::kwin::transaction_tests::duplicate_callback_path_fails_without_disturbing_its_owner
		windowing::backends::kwin::transaction_tests::transaction_times_out_and_cleans_up_when_callback_never_arrives
		windowing::backends::kwin::transaction_tests::transaction_times_out_and_cleans_up_when_load_script_never_replies
		windowing::backends::kwin::transaction_tests::transaction_times_out_and_cleans_up_when_start_never_replies
	)
	cargo_src_test
}
