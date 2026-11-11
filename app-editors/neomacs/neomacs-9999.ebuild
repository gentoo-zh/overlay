# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.96.0"

inherit cargo desktop git-r3 toolchain-funcs xdg

DESCRIPTION="Modern Emacs fork rewriting Emacs internals in Rust"
HOMEPAGE="https://github.com/eval-exec/neomacs"
EGIT_REPO_URI="https://github.com/eval-exec/neomacs.git"

LICENSE="GPL-3+ FDL-1.3+ CC-BY-SA-3.0 CC-BY-SA-4.0 CC-BY-4.0 HPND PCRE PSF-2 unicode W3C"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 CDLA-Permissive-2.0 ISC LGPL-3 MIT MPL-2.0 UoI-NCSA
	Unicode-3.0 Unicode-DFS-2016 ZLIB
"
SLOT="0"
IUSE="+jit +terminal +video"

RESTRICT="test"

DEPEND="
	dev-libs/wayland
	media-libs/fontconfig
	media-libs/mesa
	dev-db/sqlite:3
	media-libs/vulkan-loader[X,wayland]
	sys-libs/ncurses:=
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	video? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

DOCS=( README.md )

src_unpack() {
	git-r3_src_unpack
	cd "${S}" || die
	cargo_live_src_unpack
}

src_prepare() {
	default

	# Prefer Gentoo's system sqlite over rusqlite/libsqlite3-sys' bundled copy.
	sed -i -e 's/"bundled"//' Cargo.toml || die
}

src_configure() {
	local myfeatures=(
		$(usev jit)
		$(usev terminal neo-term)
		$(usev video)
	)
	cargo_src_configure --no-default-features
}

src_compile() {
	# Upstream's build script probes ncurses for the library target, but the
	# final binary also needs the full ncursesw linker set for termcap symbols.
	local ncurses_libs ncurses_link
	ncurses_libs=$("$(tc-getPKG_CONFIG)" --libs ncursesw) || die "failed to query ncursesw libs"
	for ncurses_link in ${ncurses_libs}; do
		RUSTFLAGS+=" -C link-arg=${ncurses_link}"
	done

	cargo_src_compile -p ${PN}

	cargo_env cargo xtask \
		fresh-build \
		--release \
		--skip-build \
		--bin-dir "$(cargo_target_dir)" \
		--runtime-root "${S}" || die
}

src_install() {
	local target_dir=$(cargo_target_dir)

	exeinto /usr/libexec/${PN}
	doexe "${target_dir}"/${PN}

	insinto /usr/libexec/${PN}
	doins "${target_dir}"/${PN}.pdump

	dodir /usr/bin
	cat > "${ED}"/usr/bin/${PN} <<-EOF || die
		#!/bin/sh
		export NEOMACS_RUNTIME_ROOT="\${NEOMACS_RUNTIME_ROOT:-${EPREFIX}/usr/share/${PN}}"
		exec "${EPREFIX}/usr/libexec/${PN}/${PN}" "\$@"
	EOF
	fperms 0755 /usr/bin/${PN}

	insinto /usr/share/${PN}
	doins -r etc lisp

	newicon -s scalable crates/neomacs-display-runtime/assets/window-icon.svg ${PN}.svg
	make_desktop_entry \
		--eapi9 \
		-n "Neomacs" \
		-i ${PN} \
		-c "Development;TextEditor" \
		-e "MimeType=text/plain;text/x-c;text/x-c++;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-makefile;text/x-python;text/x-rust;application/x-shellscript;" \
		-e "StartupWMClass=Neomacs" \
		${PN}

	einstalldocs
	dodoc -r docs
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Neomacs is alpha software; live builds may change or break at any time."
	if use video; then
		elog "Install GStreamer plugin packages as needed for the media formats you want to play."
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
}
