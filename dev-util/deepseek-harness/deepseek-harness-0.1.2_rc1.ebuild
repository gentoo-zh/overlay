# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Upstream/npm version string; Gentoo PV normalizes -rc.1 to _rc1.
MY_PV="0.1.2-rc.1"

DESCRIPTION="DeepSeek Harness: an agent harness by DeepSeek AI (dsh CLI)"
HOMEPAGE="https://github.com/deepseek-ai/deepseek-harness"

SRC_URI="
	https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${MY_PV}.tgz
		-> ${PN}-${MY_PV}.tgz
	https://github.com/gentoo-zh-drafts/deepseek-harness/releases/download/v${MY_PV}/${PN}-${MY_PV}-node_modules.tar.xz
"

S="${WORKDIR}/package"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"

# Prebuilt native addons ship from the npm platform packages.
QA_PREBUILT="
	usr/lib/node_modules/@deepseek-ai/dsh/node_modules/*
	usr/lib64/node_modules/@deepseek-ai/dsh/node_modules/*
"

RDEPEND=">=net-libs/nodejs-22.19"

src_prepare() {
	default
	# amd64 only ships the linux-x64 prebuilds.
	rm -rf "${S}"/node_modules/node-pty/prebuilds/win32-* \
		"${S}"/node_modules/node-pty/prebuilds/darwin-* \
		"${S}"/node_modules/node-pty/prebuilds/linux-arm64 || die
	# koffi-linux-x64 ships glibc and musl builds; keep the active libc.
	if use elibc_musl; then
		rm -rf "${S}"/node_modules/@koromix/koffi-linux-x64/linux_x64 || die
	else
		rm -rf "${S}"/node_modules/@koromix/koffi-linux-x64/musl_x64 || die
	fi
}

src_install() {
	local install_dir="/usr/$(get_libdir)/node_modules/@deepseek-ai/dsh"

	insinto "${install_dir}"
	doins -r "${S}"/*

	fperms +x "${install_dir}/lib/bin.js"

	dosym "../$(get_libdir)/node_modules/@deepseek-ai/dsh/lib/bin.js" "/usr/bin/dsh"
}

pkg_postinst() {
	elog "Run 'dsh web' (browser UI) or 'dsh --profile headless \"task\"' (one-shot); see 'dsh --help' for all profiles."
}
