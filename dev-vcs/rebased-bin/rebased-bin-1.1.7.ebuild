# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop wrapper xdg

DESCRIPTION="Git client based on the IntelliJ platform"
HOMEPAGE="https://github.com/DetachHead/rebased"
SRC_URI="
	amd64? ( https://github.com/DetachHead/rebased/releases/download/${PV}/rebased.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/DetachHead/rebased/releases/download/${PV}/rebased-aarch64.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}/${P}"

LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 CDDL-1.1
	codehaus-classworlds EPL-1.0 EPL-2.0 GPL-2-with-classpath-exception
	ISC JDOM LGPL-2.1 LGPL-2.1+ MIT MPL-1.0 MPL-1.1 OFL-1.1 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="mirror strip"

RDEPEND="
	dev-libs/wayland
	dev-vcs/git
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd[X]
	virtual/zlib:=
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxkbcommon
"

QA_PREBUILT="opt/${PN}/*"

src_unpack() {
	default
	mv "${WORKDIR}"/idea-IC-* "${S}" || die
}

src_prepare() {
	default

	cat <<-EOF >> bin/idea.properties || die
	#-----------------------------------------------------------------------
	# Disable automatic updates as these are handled through Gentoo's
	# package manager.
	#-----------------------------------------------------------------------
	ide.no.platform.update=Gentoo
	EOF
}

src_install() {
	local dir="/opt/${PN}"

	mkdir -p "${ED}${dir}" || die
	cp -a . "${ED}${dir}" || die

	make_wrapper rebased "${dir}/bin/rebased.sh" || die
	newicon -s 128 bin/rebased.png rebased.png
	newicon -s scalable bin/rebased.svg rebased.svg
	make_desktop_entry "rebased %f" "Rebased" rebased "Development;IDE;RevisionControl;" \
		"StartupWMClass=jetbrains-rebased"
}
