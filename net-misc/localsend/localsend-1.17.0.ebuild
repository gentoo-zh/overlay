# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# rhttp (a Dart HTTP plugin) builds a Rust cdylib through cargokit during the
# Flutter Linux build, so a system Rust toolchain is needed. The Flutter Linux
# toolchain itself hard-codes clang++, so an LLVM/clang slot is needed too.
LLVM_COMPAT=( 18 19 20 21 22 )
RUST_MIN_VER="1.80.0"

inherit desktop llvm-r2 rust xdg

# grep FLUTTER_VERSION .github/workflows/linux_build.yml
_FLUTTER_VERSION="3.24.5"

DESCRIPTION="An open-source cross-platform alternative to AirDrop"
HOMEPAGE="https://localsend.org"
# flutter-deps bundles the offline build inputs generated from the v${PV} tag:
# Dart pub-cache, build_runner-generated sources, the FOSS pubspec.lock and the
# vendored Rust crates for the rhttp plugin. See gentoo-zh-drafts/localsend.
SRC_URI="
	https://github.com/localsend/localsend/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/${PN}/releases/download/${PV}/${P}-flutter-deps.tar.xz
"
S="${WORKDIR}/${PN}-${PV}/app"

LICENSE="Apache-2.0"
# Vendored Rust crate licenses (rhttp plugin dependencies)
LICENSE+="
	0BSD Apache-2.0-with-LLVM-exceptions BSD BSD-2 Boost-1.0 ISC MIT
	MPL-2.0 Unicode-3.0 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="-* ~amd64"

# The bundled Flutter engine library is a prebuilt blob; libapp.so (compiled Dart)
# and librhttp.so (Rust, strip = true) come out of the release build already stripped.
QA_PREBUILT="opt/${PN}/lib/libflutter_linux_gtk.so"
QA_PRESTRIPPED="
	opt/${PN}/lib/libapp.so
	opt/${PN}/lib/libflutter_linux_gtk.so
	opt/${PN}/lib/librhttp.so
"

BDEPEND="
	${RUST_DEPEND}
	dev-build/cmake
	dev-build/ninja
	~dev-util/flutter-bin-${_FLUTTER_VERSION}
	dev-util/patchelf
	dev-vcs/git
	virtual/pkgconfig
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
	')
"
DEPEND="
	dev-libs/libayatana-appindicator
	x11-libs/gtk+:3
"
RDEPEND="
	${DEPEND}
	x11-misc/xdg-user-dirs
"

PATCHES=( "${FILESDIR}/${P}-drop-werror.patch" )

pkg_setup() {
	llvm-r2_pkg_setup
	rust_pkg_setup
}

src_unpack() {
	default
	# The flutter tool locks bin/cache even to print its version, so it needs a writable SDK; copy
	# in the shared dev-util/flutter-bin tree instead of unpacking a bundled SDK tarball here.
	cp -a "${EPREFIX}"/opt/flutter "${WORKDIR}"/flutter || die
	chmod -R u+w "${WORKDIR}"/flutter || die
}

src_prepare() {
	# Drop the proprietary in-app-purchase / donation code (upstream's FOSS build path).
	# The script cd's into app/ itself, so it must be run from the repository root.
	pushd "${WORKDIR}/${PN}-${PV}" >/dev/null || die
	sh scripts/remove_proprietary_dependencies.sh || die
	popd >/dev/null || die

	default

	# Restore the build_runner-generated sources and the matching FOSS lockfile.
	cp -a "${WORKDIR}/${P}-flutter-deps/generated-lib/." "${S}"/ || die
	cp "${WORKDIR}/${P}-flutter-deps/pubspec.lock" "${S}"/pubspec.lock || die

	# cargokit (the rhttp plugin's Rust build) drives the toolchain through rustup; shim it so it
	# uses the system Rust instead of downloading one.
	mkdir -p "${T}/bin" || die
	cat > "${T}/bin/rustup" <<-'EOF' || die
		#!/bin/sh
		case "${1}" in
			toolchain) [ "${2}" = list ] && echo "stable-x86_64-unknown-linux-gnu (default)"; exit 0 ;;
			target)    echo "x86_64-unknown-linux-gnu"; exit 0 ;;
			run)       shift 2; exec "$@" ;;
			*)         exit 0 ;;
		esac
	EOF
	chmod +x "${T}/bin/rustup" || die

	# Build the rhttp crates from the vendored sources shipped in flutter-deps, fully offline.
	mkdir -p "${T}/cargo-home" || die
	cat > "${T}/cargo-home/config.toml" <<-EOF || die
		[source.crates-io]
		replace-with = "vendored-sources"

		[source.vendored-sources]
		directory = "${WORKDIR}/${P}-flutter-deps/rust-vendor"
	EOF

	# cargokit resolves its own build_tool's Dart dependencies with a networked
	# `dart pub get`; force it offline so it uses the shipped pub-cache instead of
	# reaching pub.dev inside the network sandbox.
	sed -i 's/pub get --no-precompile/pub get --no-precompile --offline/g' \
		"${WORKDIR}/${P}-flutter-deps"/pub-cache/hosted/pub.dev/rhttp-*/cargokit/run_build_tool.sh || die

	export HOME="${T}"
	export PUB_CACHE="${WORKDIR}/${P}-flutter-deps/pub-cache"
	export FLUTTER_SUPPRESS_ANALYTICS=true

	# flutter derives its own version by running git in the SDK tree, and the vendored
	# git pub dependencies are checked out repositories too. The build user does not own
	# these trees, so without this git refuses to touch them and flutter reports its
	# version as 0.0.0-unknown, failing pub version solving.
	git config --global --add safe.directory '*' || die

	# flutter resolves its bundled flutter_tools' Dart dependencies on first use, and does
	# so online. Resolve them explicitly offline from the shipped pub-cache first, so the
	# project resolution below does not try to reach pub.dev inside the network sandbox.
	pushd "${WORKDIR}/flutter/packages/flutter_tools" >/dev/null || die
	"${WORKDIR}"/flutter/bin/cache/dart-sdk/bin/dart pub get --offline || die
	popd >/dev/null || die

	"${WORKDIR}"/flutter/bin/flutter --no-version-check pub get --offline --enforce-lockfile || die
}

src_compile() {
	export HOME="${T}"
	export PUB_CACHE="${WORKDIR}/${P}-flutter-deps/pub-cache"
	export FLUTTER_SUPPRESS_ANALYTICS=true
	export CARGO_HOME="${T}/cargo-home"
	export CARGO_NET_OFFLINE=true
	export PATH="${T}/bin:${PATH}"

	"${WORKDIR}"/flutter/bin/flutter --no-version-check build linux --release --no-pub || die
}

src_install() {
	local bundle="build/linux/x64/release/bundle"

	insinto /opt/${PN}
	doins -r "${bundle}"/{data,lib}
	exeinto /opt/${PN}
	doexe "${bundle}"/${PN}_app

	# The Flutter build bakes the build-tree ephemeral directory into each plugin's
	# RUNPATH; drop it (the libraries all sit next to each other under /opt/${PN}/lib).
	local plugin
	for plugin in "${ED}"/opt/${PN}/lib/lib*plugin.so; do
		[[ -e ${plugin} ]] || continue
		patchelf --remove-rpath "${plugin}" || die
	done

	dodir /opt/bin
	dosym -r /opt/${PN}/${PN}_app /opt/bin/${PN}

	newicon -s 128 assets/img/logo-128.png ${PN}.png
	newicon -s 256 assets/img/logo-256.png ${PN}.png

	domenu "${FILESDIR}"/${PN}.desktop
}
