# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

declare -A GIT_CRATES=(
	[mpd]='https://github.com/htkhiem/rust-mpd;0bb8342c47244548724a5b1bcc523d9ffe3ca47f;rust-mpd-%commit%'
)

LLVM_COMPAT=( {19..22} )
MY_PV="${PV}-beta"
RUST_MIN_VER="1.92.0"

inherit cargo llvm-r2 meson gnome2-utils xdg

DESCRIPTION="An MPD client with delusions of grandeur, made with Rust, GTK and Libadwaita"
HOMEPAGE="https://github.com/htkhiem/euphonica"
SRC_URI="
	https://github.com/htkhiem/euphonica/archive/v${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz
	https://github.com/gentoo-zh-drafts/euphonica/releases/download/v${MY_PV}/${PN}-${MY_PV}-crates.tar.xz
"
SRC_URI+=" ${CARGO_CRATE_URIS}"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD ISC LGPL-2.1+
	MIT MPL-2.0 UoI-NCSA openssl Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=app-crypt/libsecret-0.21.2
	>=gui-libs/gtk-4.20
	>=gui-libs/libadwaita-1.9
	>=sys-devel/gettext-0.23
	>=media-sound/mpd-0.24
	media-libs/alsa-lib
	media-video/pipewire:=
	dev-db/sqlite
	dev-libs/openssl:=
	sys-apps/xdg-desktop-portal
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	$(llvm_gen_dep 'llvm-core/clang:${LLVM_SLOT}')
"

pkg_setup() {
	llvm-r2_pkg_setup
	rust_pkg_setup
}

src_prepare () {
	default_src_prepare
}

src_unpack() {
	cargo_src_unpack
}

src_configure () {
	cargo_gen_config
	meson_src_configure
	ln -s "${CARGO_HOME}" "${BUILD_DIR}/cargo-home" || die
}

pkg_postinst () {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm () {
	xdg_pkg_postrm
	gnome2_schemas_update
}
