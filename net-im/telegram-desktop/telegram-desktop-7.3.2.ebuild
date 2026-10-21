# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	aead@0.5.2
	aes@0.8.4
	android_system_properties@0.1.6
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.102
	anyhow@1.0.104
	arrayvec@0.7.8
	askama@0.13.1
	askama@0.16.0
	askama_derive@0.13.1
	askama_derive@0.16.0
	askama_macros@0.16.0
	askama_parser@0.13.0
	askama_parser@0.16.0
	async-trait@0.1.89
	autocfg@1.5.1
	base64@0.22.1
	base64ct@1.8.3
	basic-toml@0.1.10
	bitflags@2.13.1
	bitstream-io@4.10.0
	bitvec@1.1.1
	block-buffer@0.10.4
	bnum@0.12.1
	bumpalo@3.20.3
	bytes@1.12.1
	camino@1.2.5
	cargo-platform@0.3.2
	cargo-platform@0.3.3
	cargo_metadata@0.23.1
	cc@1.4.2
	cfg-if@1.0.4
	chrono@0.4.45
	cipher@0.4.4
	clap@4.6.6
	clap_builder@4.6.6
	clap_derive@4.6.4
	clap_lex@1.1.0
	colorchoice@1.0.5
	const-oid@0.9.6
	convert_case@0.11.0
	core-foundation-sys@0.8.7
	cpufeatures@0.2.17
	crc-catalog@2.5.0
	crc@3.4.0
	crypto-common@0.1.7
	crypto_box@0.9.1
	crypto_secretbox@0.1.1
	curve25519-dalek-derive@0.1.1
	curve25519-dalek@4.1.3
	deluxe-core@0.5.0
	deluxe-macros@0.5.0
	deluxe@0.5.0
	der@0.7.10
	digest@0.10.7
	displaydoc@0.2.7
	ed25519-dalek@2.2.0
	ed25519@2.2.3
	equivalent@1.0.2
	errno@0.3.14
	fastnum@0.7.4
	fastrand@2.5.0
	fiat-crypto@0.2.9
	find-msvc-tools@0.1.10
	form_urlencoded@1.2.2
	fs-err@3.3.1
	funty@2.0.0
	futures-channel@0.3.34
	futures-core@0.3.34
	futures-executor@0.3.34
	futures-io@0.3.34
	futures-macro@0.3.34
	futures-sink@0.3.34
	futures-task@0.3.34
	futures-util@0.3.34
	futures@0.3.31
	generic-array@0.14.7
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.3
	glob@0.3.4
	goblin@0.8.2
	hashbrown@0.17.1
	heck@0.4.1
	heck@0.5.0
	hex@0.4.3
	hmac@0.12.1
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	icu_collections@2.2.0
	icu_locale_core@2.2.0
	icu_normalizer@2.2.0
	icu_normalizer_data@2.2.0
	icu_properties@2.2.0
	icu_properties_data@2.2.0
	icu_provider@2.2.0
	idna@1.1.0
	idna_adapter@1.2.2
	if_chain@1.0.3
	indexmap@2.14.0
	inout@0.1.4
	is_terminal_polyfill@1.70.2
	itoa@1.0.18
	js-sys@0.3.104
	libc@0.2.189
	libm@0.2.16
	linux-raw-sys@0.12.1
	litemap@0.8.2
	lock_api@0.4.14
	log@0.4.33
	memchr@2.8.3
	minimal-lexical@0.2.1
	no_std_io2@0.9.4
	nom@7.1.3
	num-bigint@0.4.8
	num-integer@0.1.47
	num-traits@0.2.19
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	opaque-debug@0.3.1
	ordered-float@2.10.1
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	password-hash@0.5.0
	paste@1.0.15
	pbkdf2@0.12.2
	percent-encoding@2.3.2
	pin-project-lite@0.2.17
	pkcs8@0.10.2
	plain@0.2.3
	poly1305@0.8.0
	potential_utf@0.1.5
	proc-macro-crate@1.3.1
	proc-macro-crate@3.5.0
	proc-macro2@1.0.107
	quote@1.0.47
	r-efi@5.3.0
	r-efi@6.0.0
	radium@0.7.0
	rand_core@0.6.4
	redox_syscall@0.5.18
	rustc-hash@2.1.3
	rustc_version@0.4.1
	rustix@1.1.4
	rustversion@1.0.23
	salsa20@0.10.2
	scopeguard@1.2.0
	scroll@0.12.0
	scroll_derive@0.12.1
	semver@1.0.28
	serde-aux@4.7.0
	serde-value@0.7.0
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.151
	serde_spanned@1.1.1
	sha2@0.10.9
	shlex@2.0.1
	signature@2.2.0
	siphasher@1.0.3
	slab@0.4.12
	smallvec@1.15.2
	smawk@0.3.3
	spki@0.7.3
	stable_deref_trait@1.2.1
	static_assertions@1.1.0
	strsim@0.10.0
	strsim@0.11.1
	subtle@2.6.1
	syn@2.0.119
	syn@3.0.3
	synstructure@0.13.2
	tap@1.0.1
	tempfile@3.27.0
	textwrap@0.16.2
	thiserror-impl@2.0.17
	thiserror-impl@2.0.20
	thiserror@2.0.17
	thiserror@2.0.20
	tinystr@0.8.3
	toml@1.1.4+spec-1.1.0
	toml_datetime@0.6.11
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.19.15
	toml_edit@0.25.13+spec-1.1.0
	toml_parser@1.1.3+spec-1.1.0
	toml_writer@1.1.2+spec-1.1.0
	ton_core@0.1.4
	ton_macros@0.1.2
	topological-sort@0.2.2
	typenum@1.20.1
	unicode-ident@1.0.24
	unicode-linebreak@0.1.5
	unicode-segmentation@1.13.3
	unicode-width@0.2.2
	uniffi@0.32.0
	uniffi_bindgen@0.32.0
	uniffi_core@0.32.0
	uniffi_internal_macros@0.32.0
	uniffi_macros@0.32.0
	uniffi_meta@0.32.0
	uniffi_pipeline@0.32.0
	uniffi_udl@0.32.0
	universal-hash@0.5.1
	url@2.5.7
	utf8_iter@1.0.4
	utf8parse@0.2.2
	version_check@0.9.5
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.4+wasi-0.2.12
	wasm-bindgen-macro-support@0.2.127
	wasm-bindgen-macro@0.2.127
	wasm-bindgen-shared@0.2.127
	wasm-bindgen@0.2.127
	weedle2@5.0.0
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.61.2
	winnow@0.5.40
	winnow@0.7.15
	winnow@1.0.4
	wit-bindgen@0.57.1
	writeable@0.6.3
	wyz@0.5.1
	yoke-derive@0.8.2
	yoke@0.8.3
	zerofrom-derive@0.1.7
	zerofrom@0.1.8
	zeroize@1.9.0
	zeroize_derive@1.5.0
	zerotrie@0.2.4
	zerovec-derive@0.11.3
	zerovec@0.11.6
	zmij@1.0.23
"

PYTHON_COMPAT=( python3_{12..15} )
RUST_MIN_VER="1.96.1"

inherit xdg cargo cmake python-any-r1 optfeature flag-o-matic

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org https://github.com/telegramdesktop/tdesktop"

MY_P="tdesktop-${PV}-full"
# Pinned by Telegram/build/prepare/prepare.py
TLOTTIE_COMMIT="92df98dc209bc39b1e567ec74a8c86a0af5239de"
WALLET_ENGINE_COMMIT="e59e0d89d7ee90c388bf36e3334c5b276f396697"
PATCHES_COMMIT="fe957833b84525e634a8d776a7f834ed536d9a21"
SRC_URI="
	https://github.com/telegramdesktop/tdesktop/releases/download/v${PV}/${MY_P}.tar.gz
	https://github.com/dkaraush/tlottie/archive/${TLOTTIE_COMMIT}.tar.gz
		-> tlottie-${TLOTTIE_COMMIT:0:10}.tar.gz
	https://github.com/i582/wallet-engine/archive/${WALLET_ENGINE_COMMIT}.tar.gz
		-> wallet-engine-${WALLET_ENGINE_COMMIT:0:10}.tar.gz
	https://raw.githubusercontent.com/desktop-app/patches/${PATCHES_COMMIT}/wallet-engine.patch
		-> ${PN}-wallet-engine-${PATCHES_COMMIT:0:10}.patch
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/${MY_P}"

LICENSE="BSD GPL-3-with-openssl-exception LGPL-2+"
LICENSE+=" MIT MPL-2.0 Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="dbus enchant +fonts screencast wayland webkit +X"

CDEPEND="
	!net-im/telegram-desktop-bin
	app-arch/lz4:=
	dev-cpp/abseil-cpp:=
	dev-cpp/ada:=
	dev-cpp/cld3:=
	dev-cpp/toomanycooks
	dev-libs/glib:2
	dev-libs/libfido2:=
	dev-libs/openssl:=
	dev-libs/qr-code-generator:=
	dev-libs/xxhash
	>=dev-qt/qtbase-6.11:6=[dbus?,gui,network,opengl,ssl,wayland?,widgets]
	>=dev-qt/qtimageformats-6.11:6
	>=dev-qt/qtsvg-6.11:6
	kde-frameworks/kcoreaddons:6
	media-libs/libjpeg-turbo:=
	media-libs/openal
	media-libs/rnnoise:=
	>=media-libs/tg_owt-0_pre20241202:=[screencast=,X=]
	>=media-video/ffmpeg-6:=[opus,vpx,x264]
	net-libs/tdlib:=[tde2e]
	sys-apps/hwloc:=
	virtual/minizip:=
	!enchant? ( >=app-text/hunspell-1.7:= )
	enchant? ( app-text/enchant:= )
	webkit? ( wayland? (
		>=dev-qt/qtdeclarative-6.11:6
		>=dev-qt/qtwayland-6.11:6[compositor(+),qml]
	) )
"
RDEPEND="${CDEPEND}
	webkit? ( || ( net-libs/webkit-gtk:4.1 net-libs/webkit-gtk:6 ) )
"
DEPEND="${CDEPEND}
	>=dev-cpp/cppgir-2.0_p20240315
	dev-cpp/expected
	dev-cpp/expected-lite
	>=dev-cpp/ms-gsl-4.1.0
	dev-cpp/range-v3
	>=dev-libs/protobuf-21.12
"
BDEPEND="
	${PYTHON_DEPS}
	>=dev-build/cmake-3.16
	>=dev-cpp/cppgir-2.0_p20260226
	dev-qt/qtshadertools
	>=dev-util/gdbus-codegen-2.80.5-r1
	virtual/pkgconfig
	webkit? ( wayland? ( dev-util/wayland-scanner ) )
"
# NOTE: dev-cpp/expected-lite used indirectly by a dev-cpp/cppgir header file
# NOTE: sys-apps/hwloc is depended upon by dev-cpp/toomanycooks, but needs to
#       cause SLOT rebuilds here, as dev-cpp/toomanycooks is header-only

PATCHES=(
	"${FILESDIR}"/tdesktop-5.7.2-cstring.patch
	"${FILESDIR}"/tdesktop-5.8.3-cstdint.patch
	"${FILESDIR}"/tdesktop-5.14.3-system-cppgir.patch
)

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if has ccache ${FEATURES}; then
			ewarn "ccache does not work with ${PN} out of the box"
			ewarn "due to usage of precompiled headers"
			ewarn "check bug https://bugs.gentoo.org/715114 for more info"
			ewarn
		fi
	fi
}

pkg_setup() {
	rust_pkg_setup
	python-any-r1_pkg_setup
}

src_prepare() {
	pushd "${WORKDIR}/wallet-engine-${WALLET_ENGINE_COMMIT}" >/dev/null || die
	eapply "${DISTDIR}/${PN}-wallet-engine-${PATCHES_COMMIT:0:10}.patch"
	popd >/dev/null || die

	# One staticlib for tlottie and wallet-engine, as upstream does, because
	# two Rust staticlibs would each carry std and clash at link time.
	local umbrella="${WORKDIR}/tdesktop_rust"
	mkdir -p "${umbrella}/src" || die
	cat > "${umbrella}/Cargo.toml" <<-EOF || die
		[package]
		name = "tdesktop_rust"
		version = "0.1.0"
		edition = "2024"

		[dependencies]
		tlottie = { path = "../tlottie-${TLOTTIE_COMMIT}", features = ["c-api"] }
		wallet-engine = { path = "../wallet-engine-${WALLET_ENGINE_COMMIT}" }
	EOF
	printf 'pub use ::tlottie;\npub use ::wallet_engine;\n' \
		> "${umbrella}/src/lib.rs" || die
	# Seed the lock with wallet-engine's so the versions match CRATES.
	cp "${WORKDIR}/wallet-engine-${WALLET_ENGINE_COMMIT}/Cargo.lock" \
		"${umbrella}/" || die

	# Happily fail if libraries aren't found...
	find -type f \( -name 'CMakeLists.txt' -o -name '*.cmake' \) \
		\! -path './cmake/external/qt/package.cmake' \
		-print0 | xargs -0 sed -i \
		-e '/pkg_check_modules(/s/[^ ]*)/REQUIRED &/' \
		-e '/find_package(/s/)/ REQUIRED)/' \
		-e '/find_library(/s/)/ REQUIRED)/' \
		-e '/find_path(/s/)/ REQUIRED)/' || die
	# Make sure to check the excluded files for new
	# CMAKE_DISABLE_FIND_PACKAGE/CMAKE_REQUIRE_FIND_PACKAGE entries.

	# Some packages are found through pkg_check_modules, rather than find_package
	sed -e '/find_package(lz4 /d' -i cmake/external/lz4/CMakeLists.txt || die
	sed -e '/find_package(xxHash /d' -i cmake/external/xxhash/CMakeLists.txt || die
	sed -e '/find_package(minizip /d' -i cmake/external/minizip/CMakeLists.txt || die
	# KF6WindowSystem is only used with DESKTOP_APP_DISABLE_PRIVATE_QT_API
	sed -e '/find_package(KF${QT_VERSION_MAJOR}WindowSystem /d' \
		-i Telegram/lib_base/CMakeLists.txt || die

	# Greedily remove ThirdParty directories, keep only ones that interest us
	local keep=(
		cmark-gfm  # Patched, not maintained by upstream anymore
		libprisma  # Telegram-specific library, no stable releases
		tgcalls  # Telegram-specific library, no stable releases
		xdg-desktop-portal  # Only a few xml files are used with gdbus-codegen
		MicroTeX  # Telegram-specific fork, no stable releases
		zxcvbn  # Always bundled, see Telegram/cmake/lib_zxcvbn.cmake
	)
	for x in Telegram/ThirdParty/*; do
		has "${x##*/}" "${keep[@]}" || rm -r "${x}" || die
	done

	# These libraries are used only for bundled ffmpeg, and don't need to be
	# available during build.
	: > cmake/external/openh264/CMakeLists.txt || die
	: > cmake/external/opus/CMakeLists.txt || die
	: > cmake/external/vpx/CMakeLists.txt || die

	# Control libdispatch dependency from here, as there's no
	# CMAKE_DISABLE_FIND_PACKAGE for find_library
	: > cmake/external/dispatch/CMakeLists.txt || die

	# Control QtDBus dependency from here, to avoid messing with QtGui.
	# QtGui will use find_package to find QtDbus as well, which
	# conflicts with the -DCMAKE_DISABLE_FIND_PACKAGE method.
	if ! use dbus; then
		sed -e '/find_package(Qt[^ ]* OPTIONAL_COMPONENTS/s/DBus *//' \
			-i cmake/external/qt/package.cmake || die
	fi

	# Control automagic dep only needed when USE="webkit wayland"
	if ! use webkit || ! use wayland; then
		sed -e 's/QT_CONFIG(wayland_compositor_quick)/0/' \
			-i Telegram/lib_webview/webview/platform/linux/webview_linux_compositor.h || die
	fi

	# Shut the CMake 4 QA checker up by removing unused CMakeLists files
	rm cmake/external/glib/cppgir/expected-lite/example/CMakeLists.txt || die
	rm cmake/external/glib/cppgir/expected-lite/test/CMakeLists.txt || die
	rm cmake/external/glib/cppgir/expected-lite/CMakeLists.txt || die

	# Patch around CMake 4 requirement in cmark-gfm
	# (this patch is only valid with -DCMARK_TESTS=OFF, which telegram sets)
	grep -q '^cmake_minimum_required(VERSION 3.0)$' \
		Telegram/ThirdParty/cmark-gfm/CMakeLists.txt \
		|| die 'Stale cmake patch, remove me'
	sed -e '/^cmake_minimum_required(/s/3.0/4.0/' \
		-i Telegram/ThirdParty/cmark-gfm/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	# CMake reads the generated wallet_engine.cpp at configure time, so the
	# Rust part is built here.
	local rust_out="${WORKDIR}/tdesktop_rust-out"
	local rust_target="${WORKDIR}/tdesktop_rust/$(cargo_target_dir)"
	mkdir -p "${rust_out}"/{lib,include/tlottie,include/wallet_engine} || die
	pushd "${WORKDIR}/tdesktop_rust" >/dev/null || die
	# The cdylib is for the bindgen. No --locked, cargo still adds tlottie.
	cargo_env "${CARGO}" rustc --lib $(usex debug "" --release) --offline \
		--crate-type staticlib --crate-type cdylib \
		|| die "cargo rustc tdesktop_rust failed"
	cp "${rust_target}/libtdesktop_rust.a" "${rust_out}/lib/" || die
	cp "${WORKDIR}/tlottie-${TLOTTIE_COMMIT}/include/tlottie.h" \
		"${rust_out}/include/tlottie/" || die
	# The bindgen runs `cargo metadata` in the current directory.
	CARGO_TARGET_DIR="${WORKDIR}/bindgen-target" cargo_env "${CARGO}" run \
		$(usex debug "" --release) --offline --locked \
		--manifest-path "${WORKDIR}/wallet-engine-${WALLET_ENGINE_COMMIT}/bindgen/cpp/bindgen/Cargo.toml" -- \
		--library --out-dir "${rust_out}/include/wallet_engine" \
		"${rust_target}/libtdesktop_rust.so" || die "wallet-engine bindgen failed"
	popd >/dev/null || die

	# Having user paths sneak into the build environment through the
	# XDG_DATA_DIRS variable causes all sorts of weirdness with cppgir:
	# - bug 909038: can't read from flatpak directories (fixed upstream)
	# - bug 920819: system-wide directories ignored when variable is set
	export XDG_DATA_DIRS="${ESYSROOT}/usr/share"

	# Evil flag (See https://bugs.gentoo.org/919201)
	filter-flags -fno-delete-null-pointer-checks

	# The ABI of media-libs/tg_owt breaks if the -DNDEBUG flag doesn't keep
	# the same state across both projects.
	# See https://bugs.gentoo.org/866055
	append-cppflags -DNDEBUG

	local no_webkit_wayland=$(use webkit && use wayland && echo no || echo yes)
	local use_webkit_wayland=$(use webkit && use wayland && echo yes || echo no)
	local mycmakeargs=(
		-DQT_VERSION_MAJOR=6

		# Override new cmake.eclass defaults (https://bugs.gentoo.org/921939)
		# Upstream never tests this any other way
		-DCMAKE_DISABLE_PRECOMPILE_HEADERS=OFF

		# Control automagic dependencies on certain packages
		## These libraries are only used in lib_webview, for wayland
		## See Telegram/lib_webview/webview/platform/linux/webview_linux_compositor.h
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6Quick=${no_webkit_wayland}
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6QuickWidgets=${no_webkit_wayland}
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6WaylandCompositor=${no_webkit_wayland}

		# Make sure dependencies that aren't patched to be REQUIRED in
		# src_prepare, are found.  This was suggested to me by the telegram
		# devs, in lieu of having explicit flags in the build system.
		-DCMAKE_REQUIRE_FIND_PACKAGE_Qt6DBus=$(usex dbus)
		-DCMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick=${use_webkit_wayland}
		-DCMAKE_REQUIRE_FIND_PACKAGE_Qt6QuickWidgets=${use_webkit_wayland}
		-DCMAKE_REQUIRE_FIND_PACKAGE_Qt6WaylandCompositor=${use_webkit_wayland}

		-DDESKTOP_APP_DISABLE_QT_PLUGINS=ON
		## Enables enchant and disables hunspell
		-DDESKTOP_APP_USE_ENCHANT=$(usex enchant)
		## Use system fonts instead of bundled ones
		-DDESKTOP_APP_USE_PACKAGED_FONTS=$(usex !fonts)

		-DDESKTOP_APP_TDESKTOP_RUST_LIBRARY="${rust_out}/lib/libtdesktop_rust.a"
		-DDESKTOP_APP_TLOTTIE_INCLUDE_DIR="${rust_out}/include/tlottie"
		-DDESKTOP_APP_WALLET_ENGINE_INCLUDE_DIR="${rust_out}/include/wallet_engine"
	)

	if [[ -n ${MY_TDESKTOP_API_ID} && -n ${MY_TDESKTOP_API_HASH} ]]; then
		einfo "Found custom API credentials"
		mycmakeargs+=(
			-DTDESKTOP_API_ID="${MY_TDESKTOP_API_ID}"
			-DTDESKTOP_API_HASH="${MY_TDESKTOP_API_HASH}"
		)
	else
		# https://github.com/telegramdesktop/tdesktop/blob/dev/snap/snapcraft.yaml
		# Building with snapcraft API credentials by default
		# Custom API credentials can be obtained here:
		# https://github.com/telegramdesktop/tdesktop/blob/dev/docs/api_credentials.md
		# After getting credentials you can export variables:
		#  export MY_TDESKTOP_API_ID="17349""
		#  export MY_TDESKTOP_API_HASH="344583e45741c457fe1862106095a5eb"
		# and restart the build"
		# you can set above variables (without export) in /etc/portage/env/net-im/telegram-desktop
		# portage will use custom variable every build automatically
		mycmakeargs+=(
			-DTDESKTOP_API_ID="611335"
			-DTDESKTOP_API_HASH="d524b414d21f4d37f08684c1df41ac9c"
		)
	fi

	cmake_src_configure
}

src_compile() {
	# The cppgir program causes the gen/gio/_types.hpp file to be updated.
	# Since this program can usually be invoked anywhere in the build process,
	# running it *after* some files depending on the header have been compiled
	# causes Telegram to be linked again during src_install().  This is a slow
	# process (especially with LTO), so we try to avoid it by running all
	# cppgir targets upfront.
	cmake_build $("${CMAKE_BINARY}" --build "${BUILD_DIR}" -t help | sed -n '/^[^/]*_cppgir:/s/:.*//p')
	cmake_build
	cmake_build  # Just in case, should say "no work to do"
}

pkg_postinst() {
	xdg_pkg_postinst
	if ! use X && ! use screencast; then
		ewarn "both the 'X' and 'screencast' USE flags are disabled, screen sharing won't work!"
		ewarn
	fi
	optfeature_header
	optfeature "AVIF, HEIF and JpegXL image support" kde-frameworks/kimageformats:6[avif,heif,jpegxl]
}
