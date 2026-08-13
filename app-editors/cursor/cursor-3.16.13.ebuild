# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop optfeature pax-utils shell-completion unpacker xdg

# curl -sL "https://cursor.com/api/download?platform=linux-x64&releaseTrack=latest" | jq -r '.commitSha'
BUILD_ID="ea1aa2c63ff7f41a377f250d1c8fd7dd2230e283"

DESCRIPTION="Cursor App - AI-first coding environment"
HOMEPAGE="https://cursor.com/"
SRC_URI="
	amd64? (
		https://downloads.cursor.com/production/${BUILD_ID}/linux/x64/deb/amd64/deb/cursor_${PV}_amd64.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://downloads.cursor.com/production/${BUILD_ID}/linux/arm64/deb/arm64/deb/cursor_${PV}_arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

LICENSE="cursor"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="egl kerberos wayland"
RESTRICT="bindist mirror strip"

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

CURSOR_HOME="usr/share/cursor"

pkg_setup() {
	[[ -e /usr/src/linux ]] || return
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	pushd "${CURSOR_HOME}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die
}

src_install() {
	# Updates are managed by Portage.
	sed -e "/updateUrl/d" -i "${CURSOR_HOME}/resources/app/product.json" || die

	if ! use kerberos; then
		rm -r "${CURSOR_HOME}/resources/app/node_modules/kerberos" || die
	fi

	dodir /opt/cursor
	cp -ar "${CURSOR_HOME}/." "${ED}/opt/cursor/" || die

	fperms 4711 /opt/cursor/chrome-sandbox
	pax-mark m /opt/cursor/cursor
	dosym ../cursor/bin/cursor /opt/bin/cursor

	local exec_extra_flags=()
	if use wayland; then
		exec_extra_flags+=(
			"--ozone-platform-hint=auto"
			"--enable-wayland-ime"
			"--wayland-text-input-version=3"
		)
	fi
	use egl && exec_extra_flags+=( "--use-gl=egl" )

	sed -e "s|^Exec=/.*/cursor|Exec=cursor ${exec_extra_flags[*]}|" \
		-e "s|^Icon=.*|Icon=cursor|" \
		usr/share/applications/cursor.desktop > "${T}/cursor.desktop" || die
	domenu "${T}/cursor.desktop"

	sed -e "s|^Exec=/.*/cursor|Exec=cursor ${exec_extra_flags[*]}|" \
		-e "s|^Icon=.*|Icon=cursor|" \
		usr/share/applications/cursor-url-handler.desktop \
		> "${T}/cursor-url-handler.desktop" || die
	domenu "${T}/cursor-url-handler.desktop"

	local size
	for size in 16 24 32 48 64 128 256 512 1024; do
		newicon -s "${size}" usr/share/pixmaps/co.anysphere.cursor.png cursor.png
	done

	insinto /usr/share/mime/packages
	doins usr/share/mime/packages/cursor-workspace.xml

	newbashcomp usr/share/bash-completion/completions/cursor cursor
	newzshcomp usr/share/zsh/vendor-completions/_cursor _cursor
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "desktop notifications" x11-libs/libnotify
	optfeature "keyring support inside Cursor" virtual/secret-service
}
