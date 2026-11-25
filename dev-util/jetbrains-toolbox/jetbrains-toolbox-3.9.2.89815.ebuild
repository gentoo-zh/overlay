# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Manage all your JetBrains Projects and Tools"
HOMEPAGE="https://www.jetbrains.com/toolbox-app/"
SRC_URI="
	amd64? ( https://download.jetbrains.com/toolbox/${P}.tar.gz )
	arm64? ( https://download.jetbrains.com/toolbox/${P}-arm64.tar.gz )
"

S="${WORKDIR}/${PN}/bin"

LICENSE="JetBrainsToolbox"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd
	sys-fs/fuse:0
	virtual/zlib
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libxkbcommon
"

RESTRICT="strip mirror bindist"

QA_PREBUILT="opt/${PN}/*"

src_unpack() {
	default
	# Normalize directory name for arm64
	if use arm64; then
		mv "${WORKDIR}/${P}-arm64" "${WORKDIR}/${PN}" || die
	else
		mv "${WORKDIR}/${P}" "${WORKDIR}/${PN}" || die
	fi
}

src_prepare() {
	default

	sed -i '/^MimeType=/a Categories=Development;IDE;' ${PN}.desktop || die
}

src_install() {
	domenu ${PN}.desktop

	dodir /opt/${PN}
	cp -PR --preserve=mode,timestamps . "${ED}"/opt/${PN} || die
	dosym -r /opt/${PN}/${PN} /usr/bin/${PN}
}
