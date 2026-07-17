# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=circuitjs1
DESCRIPTION="Electronic Circuit Simulator in the Browser"
HOMEPAGE="https://www.falstad.com/circuit/ https://github.com/sharpie7/circuitjs1"
SRC_URI="https://www.falstad.com/circuit/offline/${MY_PN}-linux64.tgz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# file * | grep ELF | cut -d: -f 1 | xargs -i ldd {} | grep '/usr' | cut -d' ' -f 3 | sort | uniq | xargs -i qfile {}
DEPEND="
	app-accessibility/at-spi2-core
	app-arch/brotli
	app-crypt/p11-kit
	dev-libs/glib
	dev-libs/nettle
	dev-libs/nspr
	dev-libs/nss
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/mesa
	net-dns/libidn2
	net-libs/gnutls
	net-print/cups
	sys-libs/libcap
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
"
RDEPEND="${DEPEND}"

QA_PREBUILT="
	/opt/circuitjs1/libGLESv2.so
	/opt/circuitjs1/circuitjs1
	/opt/circuitjs1/libffmpeg.so
	/opt/circuitjs1/libEGL.so
	/opt/circuitjs1/libvk_swiftshader.so
	/opt/circuitjs1/swiftshader/libGLESv2.so
	/opt/circuitjs1/swiftshader/libEGL.so
"

QA_FLAGS_IGNORED="
	/opt/circuitjs1/chrome-sandbox
	/opt/circuitjs1/libvulkan.so
"

src_install(){
	insinto "/opt/${PN}"
	doins -r .
	fperms 0755 "/opt/${PN}/${MY_PN}"
	dosym "../../opt/${PN}/${MY_PN}" "/usr/bin/${MY_PN}"
}
