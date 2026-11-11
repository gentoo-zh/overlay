# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/_pre/-preview}"
MY_PV="${MY_PV/preview[0-9]*/preview.${MY_PV##*preview}}"

inherit wrapper

DESCRIPTION="Gemini CLI - a command-line AI workflow tool by Google"
HOMEPAGE="https://github.com/google-gemini/gemini-cli"
SRC_URI="https://github.com/google-gemini/gemini-cli/releases/download/v${MY_PV}/gemini-cli-bundle.zip -> ${P}.zip"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

BDEPEND="app-arch/unzip"
RDEPEND="
	net-libs/nodejs
"

src_install() {
	insinto /usr/lib/${PN}
	doins -r .

	fperms +x /usr/lib/${PN}/gemini.js
	# Use a wrapper instead of a symlink so that Node.js ESM relative
	# imports resolve from the real install path, not the /usr/bin symlink.
	make_wrapper gemini "node /usr/lib/${PN}/gemini.js"
}
