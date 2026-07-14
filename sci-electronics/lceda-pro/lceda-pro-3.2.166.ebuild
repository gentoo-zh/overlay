# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="LCEDA Pro (binary package)"
HOMEPAGE="https://lceda.cn/"

SRC_URI="
	amd64?	( https://image.lceda.cn/files/${PN}-linux-x64-${PV}.zip )
	arm64?	( https://image.lceda.cn/files/${PN}-linux-arm64-${PV}.zip )
"
S="${WORKDIR}/lceda-pro"
LICENSE="LCEDA-EULA"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
DEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libxshmfence
	x11-libs/libXtst
	x11-libs/pango
	"
RDEPEND="${DEPEND}"
BDEPEND="app-arch/unzip"
RESTRICT="mirror"

QA_PREBUILT="
	/opt/lceda-pro/chrome-sandbox
	/opt/lceda-pro/chrome_crashpad_handler
	/opt/lceda-pro/libEGL.so
	/opt/lceda-pro/libffmpeg.so
	/opt/lceda-pro/resources/app/node_modules/sqlite3/lib/binding/napi-v3-linux-x64/node_sqlite3.node
	/opt/lceda-pro/lceda-pro
	/opt/lceda-pro/libvk_swiftshader.so
	/opt/lceda-pro/libGLESv2.so
	/opt/lceda-pro/libvulkan.so.1
"

src_install(){
	insinto /opt/lceda-pro
	doins -r .
	fperms 0755 /opt/lceda-pro/lceda-pro
	fperms 0755 /opt/lceda-pro/chrome_crashpad_handler
	domenu "${FILESDIR}"/JLCEDA_Pro.desktop
}
