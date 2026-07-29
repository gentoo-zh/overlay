# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fil fi fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv sw
	ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop xdg

DESCRIPTION="Password manager and secure wallet"
HOMEPAGE="https://1password.com"
SRC_URI="
	amd64? ( https://downloads.1password.com/linux/tar/stable/x86_64/${P}.x64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://downloads.1password.com/linux/tar/stable/aarch64/${P}.arm64.tar.gz -> ${P}-arm64.tar.gz )
"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror strip bindist"

DEPEND="
	acct-group/onepassword
	app-crypt/gnupg
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-misc/curl
	net-print/cups
	x11-libs/gtk+:3
	x11-libs/libxkbcommon
"
RDEPEND="${DEPEND}"

QA_PREBUILT="*"

pkg_setup() {
	# chromium-2 inherits linux-info, but this binary package does not need kernel probing.
	:
}

src_unpack() {
	default
	if use amd64; then
		mv ${P}.x64 ${P} || die
	elif use arm64; then
		mv ${P}.arm64 ${P} || die
	fi
}

src_prepare() {
	default
	pushd locales > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die
}

src_install() {
	local size
	for size in 32 64 256 512 ; do
		doicon -s ${size} resources/icons/hicolor/${size}x${size}/apps/1password.png
	done
	rm -rf resources/icons || die

	domenu resources/1password.desktop

	exeinto /opt/1Password/
	doexe 1password 1Password-{BrowserSupport,Crash-Handler,LastPass-Exporter} op-ssh-sign
	doexe chrome-sandbox chrome_crashpad_handler *.so*

	insinto /etc/1password/
	insopts -m0755
	doins resources/custom_allowed_browsers

	insinto /opt/1Password/
	doins *.pak *.bin *.json *.dat
	insopts -m0755
	doins -r locales resources

	# Chrome-sandbox requires the setuid bit to be specifically set.
	# see https://github.com/electron/electron/issues/17972
	fperms 4755 /opt/1Password/chrome-sandbox

	fowners root:onepassword /opt/1Password/1Password-BrowserSupport
	fperms g+s /opt/1Password/1Password-BrowserSupport

	dosym ../../opt/1Password/1password /usr/bin/1password
}
