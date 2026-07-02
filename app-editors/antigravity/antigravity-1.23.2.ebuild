# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop optfeature pax-utils unpacker xdg shell-completion

# curl -sL https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/dists/antigravity-debian/main/binary-amd64/Packages | tac | sed -e '/^$/q' | grep Filename
MY_PV_SUFFIX_AMD64="1776332190_amd64_d29aa2e214aa69c5a7199fce43624422"
# curl -sL https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/dists/antigravity-debian/main/binary-arm64/Packages | tac | sed -e '/^$/q' | grep Filename
MY_PV_SUFFIX_ARM64="1776332230_arm64_cdd44fd493c967bb35c13b3b2c49e726"

DESCRIPTION="Google Antigravity - AI-powered code editor"
HOMEPAGE="https://antigravity.google/"
SRC_URI="
	amd64? (
		https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/pool/antigravity-debian/antigravity_${PV}-${MY_PV_SUFFIX_AMD64}.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/pool/antigravity-debian/antigravity_${PV}-${MY_PV_SUFFIX_ARM64}.deb
			-> ${P}-arm64.deb
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
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/libglvnd
	media-libs/mesa
	net-misc/curl
	net-print/cups
	sys-apps/dbus
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
	)
"

QA_PREBUILT="*"

ANTIGRAVITY_HOME="usr/share/antigravity"

src_configure() {
	default
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default
	pushd "${ANTIGRAVITY_HOME}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die
}

src_install() {
	cd "${ANTIGRAVITY_HOME}" || die

	# Cleanup
	rm ./resources/app/ThirdPartyNotices.txt || die

	# Disable update server
	sed -e "/updateUrl/d" -i ./resources/app/product.json || die

	if ! use kerberos; then
		rm -r ./resources/app/node_modules/kerberos || die
	fi

	if ! use webkit; then
		rm -r ./resources/app/extensions/microsoft-authentication || die
	fi

	# Install main application
	pax-mark m antigravity
	mkdir -p "${ED}/opt/${PN}" || die
	cp -a . "${ED}/opt/${PN}" || die
	fperms 4711 /opt/${PN}/chrome-sandbox

	dosym -r "/opt/${PN}/bin/antigravity" "usr/bin/antigravity"
	dosym -r "/opt/${PN}/bin/antigravity" "usr/bin/agy"

	local EXEC_EXTRA_FLAGS=()
	if use wayland; then
		EXEC_EXTRA_FLAGS+=( "--ozone-platform-hint=auto" "--enable-wayland-ime" "--wayland-text-input-version=3" )
	fi
	if use egl; then
		EXEC_EXTRA_FLAGS+=( "--use-gl=egl" )
	fi

	# Desktop files from deb package
	cd "${WORKDIR}" || die
	if [[ -f usr/share/applications/antigravity.desktop ]]; then
		sed "s|Exec=/usr/share/antigravity/antigravity|Exec=antigravity ${EXEC_EXTRA_FLAGS[*]}|" \
			usr/share/applications/antigravity.desktop \
			> "${T}/antigravity.desktop" || die
		domenu "${T}/antigravity.desktop"
	fi

	if [[ -f usr/share/applications/antigravity-url-handler.desktop ]]; then
		sed "s|Exec=/usr/share/antigravity/antigravity|Exec=antigravity ${EXEC_EXTRA_FLAGS[*]}|" \
			usr/share/applications/antigravity-url-handler.desktop \
			> "${T}/antigravity-url-handler.desktop" || die
		domenu "${T}/antigravity-url-handler.desktop"
	fi

	# Install icon
	if [[ -f usr/share/pixmaps/antigravity.png ]]; then
		doicon usr/share/pixmaps/antigravity.png
	fi

	# Install metainfo if available
	if [[ -d usr/share/appdata ]]; then
		local appdata_xml=( usr/share/appdata/*.xml )
		if [[ -e ${appdata_xml[0]} ]]; then
			insinto /usr/share/metainfo
			doins "${appdata_xml[@]}"
		fi
	fi

	# Install MIME type definitions if available
	if [[ -d usr/share/mime/packages ]]; then
		local mime_xml=( usr/share/mime/packages/*.xml )
		if [[ -e ${mime_xml[0]} ]]; then
			insinto /usr/share/mime/packages
			doins "${mime_xml[@]}"
		fi
	fi

	# Install completions
	if [[ -f usr/share/bash-completion/completions/antigravity ]]; then
		newbashcomp usr/share/bash-completion/completions/antigravity antigravity
	fi
	if [[ -f usr/share/zsh/vendor-completions/_antigravity ]]; then
		newzshcomp usr/share/zsh/vendor-completions/_antigravity _antigravity
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "desktop notifications" x11-libs/libnotify
	optfeature "keyring support" "virtual/secret-service"
}
