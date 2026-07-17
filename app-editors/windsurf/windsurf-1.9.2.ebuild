# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop shell-completion unpacker xdg

DESCRIPTION="AI-powered code editor maintaining flow state with instant assistance"
HOMEPAGE="https://devin.ai/desktop"

SRC_URI="https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt/pool/main/w/windsurf/Windsurf-linux-x64-${PV}.deb"
S="${WORKDIR}"

# License same as vscode
LICENSE="
	Apache-2.0
	BSD
	BSD-1
	BSD-2
	BSD-4
	CC-BY-4.0
	ISC
	LGPL-2.1+
	Microsoft-vscode
	MIT
	MPL-2.0
	openssl
	PYTHON
	TextMate-bundle
	Unlicense
	UoI-NCSA
	W3C
"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="egl kerberos wayland"
RESTRICT="mirror strip bindist"

RDEPEND="
	|| (
		sys-apps/systemd
		sys-apps/systemd-utils
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret[crypt]
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/libglvnd
	media-libs/mesa
	net-misc/curl
	sys-apps/dbus
	virtual/zlib
	sys-process/lsof
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/pango
	x11-misc/xdg-utils
	kerberos? ( app-crypt/mit-krb5 )
"

QA_PREBUILT="*"

src_install() {
	# Install application files and keep the original permissions
	mkdir -p "${ED}/opt/${PN}" || die
	cp -r "${S}/usr/share/windsurf/"* "${ED}/opt/${PN}" || die

	# Fix chrome-sandbox permissions
	fperms 4755 /opt/windsurf/chrome-sandbox

	# Install launcher script
	dosym ../../opt/windsurf/windsurf /usr/bin/windsurf

	# Fix path and executable flags in desktop files
	local EXEC_EXTRA_FLAGS=()
	if use wayland; then
		EXEC_EXTRA_FLAGS+=( "--ozone-platform-hint=auto" "--enable-wayland-ime" "--wayland-text-input-version=3" )
	fi
	if use egl; then
		EXEC_EXTRA_FLAGS+=( "--use-gl=egl" )
	fi
	sed -i \
	    -e "s|/usr/share/windsurf/windsurf|/opt/windsurf/windsurf ${EXEC_EXTRA_FLAGS[*]} |g" \
		"${S}/usr/share/applications/windsurf.desktop" \
		"${S}/usr/share/applications/windsurf-url-handler.desktop" \
		|| die "sed failed"

	# Install desktop files
	domenu "${S}/usr/share/applications/windsurf.desktop"
	domenu "${S}/usr/share/applications/windsurf-url-handler.desktop"

	# Install icon
	doicon "${S}/usr/share/pixmaps/windsurf.png"

	# Install metainfo
	insinto /usr/share/metainfo
	doins "${S}/usr/share/appdata/windsurf.appdata.xml"

	# Install MIME type definitions
	insinto /usr/share/mime/packages
	doins "${S}/usr/share/mime/packages/windsurf-workspace.xml"

	# Install completions
	newbashcomp "${S}/usr/share/bash-completion/completions/windsurf" windsurf
	newzshcomp "${S}/usr/share/zsh/vendor-completions/_windsurf" _windsurf
}
