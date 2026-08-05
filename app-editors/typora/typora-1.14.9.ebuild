# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="A truely minimal markdown editor"
HOMEPAGE="https://typora.io"
SRC_URI="
	amd64? ( https://download.typora.io/linux/typora_${PV}_amd64.deb )
	arm64? ( https://download.typora.io/linux/typora_${PV}_arm64.deb )
"
S="${WORKDIR}"

LICENSE="typora-2026"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RESTRICT="bindist mirror splitdebug strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/libudev:0/1
	x11-libs/cairo
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxkbcommon
	x11-libs/pango
"

QA_PREBUILT="
	usr/share/typora/Typora
	usr/share/typora/chrome-sandbox
	usr/share/typora/chrome_crashpad_handler
	usr/share/typora/libEGL.so
	usr/share/typora/libGLESv2.so
	usr/share/typora/libffmpeg.so
	usr/share/typora/libvk_swiftshader.so
	usr/share/typora/libvulkan.so.1
	usr/share/typora/resources/node_modules/cld/build/Release/cld.node
	usr/share/typora/resources/node_modules/fswin/build/Release/fswin.node
	usr/share/typora/resources/node_modules/main.node
	usr/share/typora/resources/node_modules/vscode-ripgrep/bin/rg
"

src_install() {
	mv "${S}/usr" "${D}" || die

	pushd "${D}/usr/share/doc" > /dev/null || die
	mv ${PN} ${P} || die
	popd > /dev/null || die
	docompress -x "/usr/share/doc/${P}"

	fperms 4755 /usr/share/typora/chrome-sandbox
	fperms 0644 \
		/usr/share/typora/resources/packages/node-spellchecker/vendor/hunspell_dictionaries/en_US.{aff,dic}
}
