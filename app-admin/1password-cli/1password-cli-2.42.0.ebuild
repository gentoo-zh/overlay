# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Command line interface for the 1Password password manager"
HOMEPAGE="https://www.1password.dev/cli"
SRC_URI="
	amd64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${PV}/op_linux_amd64_v${PV}.zip -> ${P}-amd64.zip )
	arm64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${PV}/op_linux_arm64_v${PV}.zip -> ${P}-arm64.zip )
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror"

RDEPEND="
	acct-group/onepassword-cli
	!app-admin/op-cli-bin
"
BDEPEND="
	acct-group/onepassword-cli
	app-arch/unzip
"

QA_PREBUILT="usr/bin/op"

src_install() {
	dobin op
	# the desktop app resets a connection unless the GID of the connecting process
	# is onepassword-cli, so op runs setgid to that group
	fowners root:onepassword-cli /usr/bin/op
	fperms 2755 /usr/bin/op
}
