# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="An open-source AI agent that lives in your terminal"
HOMEPAGE="https://github.com/QwenLM/qwen-code"
SRC_URI="https://registry.npmjs.org/@qwen-code/${PN}/-/${P}.tgz"
S="${WORKDIR}/package"

LICENSE="Apache-2.0 BSD ISC MIT || ( Apache-2.0 MPL-2.0 ) || ( MIT Unlicense )"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
QA_PREBUILT="
	usr/lib*/node_modules/@qwen-code/${PN}/vendor/ripgrep/*-linux/rg
	usr/lib*/node_modules/@qwen-code/${PN}/vendor/landlock-run/*-linux/qwen-landlock-run
	usr/lib*/node_modules/@qwen-code/${PN}/opentui-assets/@opentui/core-linux-*/libopentui.so
"

RDEPEND=">=net-libs/nodejs-22"

src_prepare() {
	default

	local other=arm64
	use arm64 && other=x64
	rm -r vendor/ripgrep/*-{darwin,win32} vendor/{ripgrep,landlock-run}/${other}-linux \
		opentui-assets/@opentui/core-{darwin-*,linux-${other}} || die
}

src_install() {
	local dir=/usr/$(get_libdir)/node_modules/@qwen-code/${PN}
	local arch=x64
	use arm64 && arch=arm64

	insinto "${dir}"
	doins -r .
	fperms +x "${dir}"/{cli-entry.js,vendor/{ripgrep/${arch}-linux/rg,landlock-run/${arch}-linux/qwen-landlock-run}}
	dosym -r "${dir}/cli-entry.js" /usr/bin/qwen
}
