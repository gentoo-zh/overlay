# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop optfeature pax-utils xdg

MY_BUILD="6512087774658560"
ICON_COMMIT="8182e2d354c6b096e544f24b3ea8fcfb5e73d699"

DESCRIPTION="Google Antigravity multi-agent orchestration platform"
HOMEPAGE="https://antigravity.google/product/antigravity-2"
SRC_URI="
	https://aur.archlinux.org/cgit/aur.git/plain/antigravity.png?h=antigravity&id=${ICON_COMMIT}
		-> ${P}.png
	amd64? (
		https://storage.googleapis.com/antigravity-public/antigravity-hub/${PV}-${MY_BUILD}/linux-x64/Antigravity.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://storage.googleapis.com/antigravity-public/antigravity-hub/${PV}-${MY_BUILD}/linux-arm/Antigravity.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Google-TOS"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="+cli egl +ide wayland"
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
	net-print/cups
	sys-apps/dbus
	sys-libs/glibc
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
	x11-libs/libXrandr
	x11-libs/pango
	x11-misc/xdg-utils
"
PDEPEND="
	cli? ( >=dev-util/antigravity-cli-1 )
	ide? ( >=app-editors/antigravity-ide-2 )
"
BDEPEND="dev-util/patchelf"

QA_PREBUILT="*"

src_unpack() {
	default
	mv Antigravity-* "${PN}" || die
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

	# Upstream builds webm_encoder against Google's internal runtime loader.
	local interpreter
	interpreter=$(patchelf --print-interpreter "${EPREFIX}"/bin/bash) || die
	patchelf --set-interpreter "${interpreter}" "${PN}/resources/bin/webm_encoder" || die

	# Updates are managed by Portage.
	rm "${PN}/resources/app-update.yml" || die
}

src_install() {
	cd "${PN}" || die
	pax-mark m antigravity

	mkdir -p "${ED}/opt/${PN}" || die
	cp -r . "${ED}/opt/${PN}" || die
	fperms 4711 /opt/${PN}/chrome-sandbox

	dosym -r /opt/${PN}/antigravity /usr/bin/antigravity

	local exec_extra_flags=()
	if use wayland; then
		exec_extra_flags+=(
			"--ozone-platform-hint=auto"
			"--enable-wayland-ime"
			"--wayland-text-input-version=3"
		)
	fi
	use egl && exec_extra_flags+=( "--use-gl=egl" )

	make_desktop_entry --eapi9 antigravity -a "${exec_extra_flags[*]} %U" \
		-n Antigravity -i antigravity -c Development -e "GenericName=Agentic Platform" \
		-e "StartupNotify=false" -e "StartupWMClass=Antigravity"
	newicon "${DISTDIR}/${P}.png" antigravity.png

	dodoc LICENSE.electron.txt LICENSES.chromium.html
}

pkg_postinst() {
	xdg_pkg_postinst

	local replacing
	for replacing in ${REPLACING_VERSIONS}; do
		if ver_test "${replacing}" -lt 2; then
			elog "Antigravity 2.x split the original editor into three packages:"
			elog "  app-editors/antigravity provides the Hub (/usr/bin/antigravity)."
			elog "  app-editors/antigravity-ide provides the IDE (/usr/bin/antigravity-ide)."
			elog "  dev-util/antigravity-cli provides the CLI (/usr/bin/agy)."
			elog "The default-enabled cli and ide USE flags install both companion packages."
			elog "Existing user files are left untouched."
			elog
			elog "Antigravity 2.x 已將原編輯器拆分為三個套件："
			elog "  app-editors/antigravity 提供 Hub（/usr/bin/antigravity）。"
			elog "  app-editors/antigravity-ide 提供 IDE（/usr/bin/antigravity-ide）。"
			elog "  dev-util/antigravity-cli 提供 CLI（/usr/bin/agy）。"
			elog "預設啟用的 cli 與 ide USE flag 會安裝兩個配套套件。"
			elog "現有的使用者檔案不會被修改。"
			break
		fi
	done

	optfeature "desktop notifications" x11-libs/libnotify
	optfeature "keyring service" virtual/secret-service
}
