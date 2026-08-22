# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

declare -A GIT_CRATES=(
	[mpd]='https://github.com/htkhiem/rust-mpd;218e1af6c44e08101b3c99f0df0fe1d10c3702b4;rust-mpd-%commit%'
)

RUST_MIN_VER="1.88.0"

inherit cargo meson gnome2-utils xdg

DESCRIPTION="An MPD client with delusions of grandeur, made with Rust, GTK and Libadwaita"
HOMEPAGE="https://github.com/htkhiem/euphonica"
SRC_URI="
	https://github.com/htkhiem/euphonica/archive/v${PV}-beta.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/euphonica/releases/download/v${PV}-beta/${P}-beta-crates.tar.xz
"
SRC_URI+=" ${CARGO_CRATE_URIS}"
S="${WORKDIR}/${P}-beta"

LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD ISC LGPL-2.1+
	MIT MPL-2.0 UoI-NCSA openssl Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=gui-libs/gtk-4.21:4=
	>=gui-libs/libadwaita-1.9:1=
	>=sys-devel/gettext-0.23
	>=media-sound/mpd-0.24
	dev-db/sqlite
	>=app-crypt/libsecret-0.21.2:0=
	sys-apps/xdg-desktop-portal
"
DEPEND="${RDEPEND}"

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
