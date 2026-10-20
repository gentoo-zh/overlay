# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.92.0"

inherit cargo

DESCRIPTION="Yet another Japanese IME for IBus"
HOMEPAGE="https://github.com/akaza-im/akaza"
SRC_URI="
	https://github.com/akaza-im/akaza/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/akaza/releases/download/v${PV}/${P}-crates.tar.xz
	https://github.com/akaza-im/akaza/releases/download/v${PV}/akaza-default-model.tar.gz
		-> ${P}-default-model.tar.gz
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD MIT MPL-2.0
	Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	app-i18n/ibus
	gui-libs/gtk:4
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_compile() {
	cargo_src_compile -p ibus-akaza -p akaza-conf -p akaza-dict -p akaza-data
}

src_install() {
	cargo_src_install --path ibus-akaza
	cargo_src_install --path akaza-conf
	cargo_src_install --path akaza-dict
	cargo_src_install --path akaza-data

	sed -e "s:@BINARY@:${EPREFIX}/usr/bin/ibus-akaza:" -e "s:@DATADIR@:${EPREFIX}/usr/share:" \
		ibus-akaza/akaza.xml.in > akaza.xml || die
	insinto /usr/share/ibus/component
	doins akaza.xml
	insinto /usr/share/ibus-akaza
	doins ibus-akaza/akaza.svg

	insinto /usr/share/akaza/romkan
	doins romkan/*.json
	insinto /usr/share/akaza/keymap
	doins keymap/*.json
	insinto /usr/share/akaza/model/default
	doins "${WORKDIR}"/akaza-default-model/*
}
