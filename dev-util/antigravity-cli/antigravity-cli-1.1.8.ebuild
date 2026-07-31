# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Google Antigravity terminal agent (prebuilt binary)"
HOMEPAGE="https://antigravity.google/product/antigravity-cli https://github.com/google-antigravity/antigravity-cli"
SRC_URI="
	amd64? (
		https://github.com/google-antigravity/antigravity-cli/releases/download/${PV}/agy_cli_linux_x64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/google-antigravity/antigravity-cli/releases/download/${PV}/agy_cli_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Google-TOS"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	sys-libs/glibc
"

QA_PREBUILT="usr/bin/agy"

src_install() {
	newbin antigravity agy
	newenvd - 50antigravity-cli <<<"AGY_CLI_DISABLE_AUTO_UPDATE=true"
}
