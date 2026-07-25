# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# OpenBangla-Keyboard only grows a Fcitx5 backend on the develop branch, so this
# is a snapshot; riti and corrosion are git submodules the archive omits.
OB_COMMIT="f83d5d065f3990287da33e4c9254668ff1b2c440"
RITI_COMMIT="afee54a79e230165d38f6b17161cd8ff971e1c49"
CORROSION_COMMIT="f88df62d022d5a3a51118b0c8871f5d6b38a4771"

CRATES="
	ahash@0.8.12
	aho-corasick@1.1.4
	cfg-if@1.0.4
	diff@0.1.13
	edit-distance@2.2.2
	emojicon@0.5.0
	fst@0.4.7
	getrandom@0.3.4
	itoa@1.0.18
	libc@0.2.189
	memchr@2.8.3
	okkhor@0.8.2
	once_cell@1.20.3
	phf@0.11.3
	phf_generator@0.11.3
	phf_macros@0.11.3
	phf_shared@0.11.3
	poriborton@0.2.3
	pretty_assertions@1.4.1
	proc-macro2@1.0.107
	quote@1.0.47
	r-efi@5.3.0
	rand@0.8.7
	rand_core@0.6.4
	regex@1.13.1
	regex-automata@0.4.16
	regex-syntax@0.8.11
	rustversion@1.0.23
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.151
	siphasher@1.0.3
	stringplus@0.1.0
	syn@2.0.119
	syn@3.0.3
	unicode-ident@1.0.24
	upodesh@0.4.0
	version_check@0.9.5
	wasip2@1.0.4+wasi-0.2.12
	wit-bindgen@0.57.1
	yansi@1.0.1
	zerocopy@0.8.55
	zerocopy-derive@0.8.55
	zmij@1.0.23
"

# wasip2 in the crate graph requires Rust 1.87.
RUST_MIN_VER="1.87.0"

inherit cargo cmake xdg

DESCRIPTION="OpenBangla Bengali (Avro Phonetic) input method engine for Fcitx5"
HOMEPAGE="https://openbangla.org/ https://github.com/OpenBangla/OpenBangla-Keyboard"
SRC_URI="
	https://github.com/OpenBangla/OpenBangla-Keyboard/archive/${OB_COMMIT}.tar.gz
		-> ${P}.tar.gz
	https://github.com/OpenBangla/riti/archive/${RITI_COMMIT}.tar.gz
		-> riti-${RITI_COMMIT}.tar.gz
	https://github.com/corrosion-rs/corrosion/archive/${CORROSION_COMMIT}.tar.gz
		-> corrosion-${CORROSION_COMMIT}.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/OpenBangla-Keyboard-${OB_COMMIT}"

# GPL-3+: OpenBangla and riti; remainder: bundled crates.
LICENSE="GPL-3+ Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 LGPL-2.1+ MIT Unicode-3.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=app-i18n/fcitx-5.0.5:5
	app-arch/zstd
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-fcitx-only.patch
)

src_prepare() {
	# The release archive carries empty submodule mount points; drop them and
	# graft in the separately fetched riti engine and corrosion CMake helper.
	rm -rf src/engine/riti cmake/corrosion-rs || die
	mv "${WORKDIR}/riti-${RITI_COMMIT}" src/engine/riti || die
	mv "${WORKDIR}/corrosion-${CORROSION_COMMIT}" cmake/corrosion-rs || die
	# riti ships no Cargo.lock; supply the one pinning the vendored CRATES.
	cp "${FILESDIR}"/riti-afee54a7-Cargo.lock src/engine/riti/Cargo.lock || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_FCITX=ON
		-DENABLE_IBUS=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# The Qt5 settings GUI is not built, so its desktop launcher and AppStream
	# metadata would only dangle; the engine keeps its layouts, data and icon.
	rm "${ED}"/usr/share/applications/openbangla-keyboard.desktop || die
	rm "${ED}"/usr/share/metainfo/io.github.openbangla.keyboard.metainfo.xml || die
}
