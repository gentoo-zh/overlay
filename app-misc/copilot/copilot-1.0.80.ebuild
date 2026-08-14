# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The power of GitHub Copilot, now in your terminal"
HOMEPAGE="https://github.com/github/copilot-cli"
# Upstream ships the native executable in per-platform packages
# @github/copilot-<os>-<arch>, not in @github/copilot; install the linux-x64 one.
SRC_URI="amd64? ( https://registry.npmjs.org/@github/copilot-linux-x64/-/copilot-linux-x64-${PV}.tgz -> ${P}-amd64.tgz )"
S="${WORKDIR}/package"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="opt/${PN}/*"

src_install() {
	# Drop bundled native addons for other OSes/arches (this is the linux amd64 package).
	local clip="clipboard/node_modules/@teddyzhu/clipboard"
	rm "${clip}"/clipboard.{darwin-arm64,darwin-x64,linux-arm64-gnu,win32-arm64-msvc,win32-x64-msvc}.node || die

	# The bundled webview native addon links libxdo.so.3 (Gentoo ships libxdo.so.4)
	# and a webkit2gtk/gtk3 stack; it only drives the optional canvas UI, from which
	# the CLI falls back cleanly. Drop it rather than pull in that desktop stack.
	rm -r "${S}"/webview/node_modules/@webviewjs/webview-linux-x64-gnu || die

	dodoc README.md
	rm -f README.md LICENSE.md || die

	insinto /opt/${PN}
	doins -r .
	fperms a+x "/opt/${PN}/copilot"

	dodir /opt/bin
	dosym -r "/opt/${PN}/copilot" /opt/bin/copilot
}
