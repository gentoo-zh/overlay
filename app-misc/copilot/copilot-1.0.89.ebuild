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
	dodoc README.md
	rm -f README.md LICENSE.md || die

	insinto /opt/${PN}
	doins -r .
	fperms a+x "/opt/${PN}/copilot"

	dodir /opt/bin
	dosym -r "/opt/${PN}/copilot" /opt/bin/copilot
}
