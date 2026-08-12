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
IUSE="mcp policykit"
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
RDEPEND="
	${DEPEND}
	mcp? ( acct-group/onepassword-mcp )
	policykit? ( sys-auth/polkit[pam] )
"

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
	if use mcp; then
		doexe 1password-mcp
	fi

	insinto /etc/1password/
	insopts -m0644
	doins resources/custom_allowed_browsers

	if use policykit; then
		insinto /usr/share/polkit-1/actions
		insopts -m0644
		newins com.1password.1Password.policy.tpl com.1password.1Password.policy
	fi

	insinto /opt/1Password/
	insopts -m0755
	doins *.pak *.bin *.json *.dat
	doins -r locales resources

	docinto examples
	dodoc resources/custom_allowed_browsers

	# Chrome-sandbox requires the setuid bit to be specifically set.
	# see https://github.com/electron/electron/issues/17972
	fperms 4755 /opt/1Password/chrome-sandbox

	fowners root:onepassword /opt/1Password/1Password-BrowserSupport
	fperms g+s /opt/1Password/1Password-BrowserSupport

	dosym ../../opt/1Password/1password /usr/bin/1password
	dosym ../../opt/1Password/op-ssh-sign /usr/bin/op-ssh-sign

	if use mcp; then
		# Upstream after-install.sh: setgid so OPH can verify MCP peers via SO_PEERCRED.
		fowners root:onepassword-mcp /opt/1Password/1password-mcp
		fperms g+s /opt/1Password/1password-mcp
		dosym ../../opt/1Password/1password-mcp /usr/bin/1password-mcp
		# Pre-rename alias retained by upstream after-install.sh.
		dosym 1password-mcp /opt/1Password/onepassword-mcp
	fi
}

pkg_preinst() {
	xdg_pkg_preinst

	use policykit || return 0

	[[ -r ${EROOT}/etc/passwd ]] || die "Unable to read ${EROOT}/etc/passwd"

	local -a policy_owners=()
	local username uid

	# Same as install_biometrics_policy.sh: first ten accounts with
	# four-digit UIDs.
	while IFS=: read -r username _ uid _; do
		[[ ${uid} =~ ^[0-9]{4}$ ]] || continue
		policy_owners+=( "unix-user:${username}" )
		(( ${#policy_owners[@]} == 10 )) && break
	done < "${EROOT}"/etc/passwd

	sed -i -e "s/\${POLICY_OWNERS}/${policy_owners[*]}/" \
		"${ED}"/usr/share/polkit-1/actions/com.1password.1Password.policy || die
}

pkg_postinst() {
	xdg_pkg_postinst
	use policykit || return 0

	elog "The Polkit policy owner list contains the first ten accounts with"
	elog "four-digit UIDs that existed when this package was merged. Re-emerge"
	elog "${CATEGORY}/${PN} after adding an eligible account."
}
