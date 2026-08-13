# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop optfeature pax-utils shell-completion xdg

MY_BUILD="6697361355964416"

DESCRIPTION="Google Antigravity agent-first development environment"
HOMEPAGE="https://antigravity.google/"
SRC_URI="
	amd64? (
		https://dl.google.com/release2/j0qc3/antigravity/stable/${PV}-${MY_BUILD}/linux-x64/Antigravity%20IDE.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://dl.google.com/release2/j0qc3/antigravity/stable/${PV}-${MY_BUILD}/linux-arm/Antigravity%20IDE.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Google-TOS"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="egl kerberos wayland webkit"
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
	dev-libs/openssl:0/3
	media-libs/alsa-lib
	media-libs/libglvnd
	media-libs/mesa
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	sys-libs/glibc
	sys-process/lsof
	virtual/zlib:=
	x11-libs/cairo
	x11-libs/gtk+:3
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
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/pango
	x11-misc/xdg-utils
	kerberos? ( app-crypt/mit-krb5 )
	webkit? (
		net-libs/libsoup:3.0
		net-libs/webkit-gtk:4.1
		sys-apps/util-linux
	)
"

QA_PREBUILT="*"

src_unpack() {
	default
	mv "Antigravity IDE" "${PN}" || die
}

pkg_setup() {
	[[ -e /usr/src/linux ]] || return
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	pushd "${PN}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die
}

src_install() {
	cd "${PN}" || die

	# Updates are managed by Portage.
	sed -e "/updateUrl/d" -i resources/app/product.json || die

	if ! use kerberos; then
		rm -r resources/app/node_modules/kerberos || die
	fi

	if ! use webkit; then
		rm -r resources/app/extensions/microsoft-authentication || die
	fi

	pax-mark m antigravity-ide
	mkdir -p "${ED}/opt/${PN}" || die
	cp -r . "${ED}/opt/${PN}" || die
	fperms 4711 /opt/${PN}/chrome-sandbox

	dosym -r "/opt/${PN}/bin/antigravity-ide" "/usr/bin/antigravity-ide"

	local exec_extra_flags=()
	if use wayland; then
		exec_extra_flags+=(
			"--ozone-platform-hint=auto"
			"--enable-wayland-ime"
			"--wayland-text-input-version=3"
		)
	fi
	use egl && exec_extra_flags+=( "--use-gl=egl" )

	make_desktop_entry --eapi9 antigravity-ide -a "${exec_extra_flags[*]} %F" \
		-n "Antigravity IDE" -i antigravity-ide -c "TextEditor;Development;IDE" \
		-e "GenericName=Text Editor" -e "StartupNotify=false" \
		-e "StartupWMClass=antigravity-ide" \
		-e "MimeType=application/x-antigravity-ide-workspace"
	make_desktop_entry --eapi9 antigravity-ide \
		-a "${exec_extra_flags[*]} --open-url %U" -d antigravity-ide-url-handler \
		-n "Antigravity IDE - URL Handler" -i antigravity-ide \
		-c "Utility;TextEditor;Development;IDE" -e "NoDisplay=true" \
		-e "StartupNotify=true" -e "MimeType=x-scheme-handler/antigravity-ide"

	newicon resources/app/resources/linux/code.png antigravity-ide.png

	insinto /usr/share/mime/packages
	doins "${FILESDIR}/antigravity-ide-workspace.xml"

	newbashcomp resources/completions/bash/antigravity-ide antigravity-ide
	dozshcomp resources/completions/zsh/_antigravity-ide

	dodoc resources/app/LICENSE.txt resources/app/ThirdPartyNotices.txt LICENSES.chromium.html
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "desktop notifications" x11-libs/libnotify
	optfeature "keyring service" virtual/secret-service
}
