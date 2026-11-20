# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="LLM frontend for power users: text generation, image generation and TTS"
HOMEPAGE="https://docs.sillytavern.app/"
SRC_URI="
	https://github.com/SillyTavern/SillyTavern/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/SillyTavern/releases/download/v${PV}/${PN}-${PV}-node_modules.tar.xz
"
S="${WORKDIR}/SillyTavern-${PV}"

LICENSE="AGPL-3 0BSD Apache-2.0 BlueOak-1.0.0 BSD BSD-2 CC-BY-4.0 ISC LGPL-3 MIT WTFPL-2 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test"

RDEPEND="
	dev-vcs/git
	>=net-libs/nodejs-20
"

src_install() {
	local dir=/usr/share/${PN}
	local f

	insinto "${dir}"
	doins server.js package.json plugins.js webpack.config.js
	doins -r src public default plugins
	doins -r "${WORKDIR}"/node_modules

	# The server mkdirs these relative to its own directory when missing,
	# which fails under the read-only /usr/share.
	keepdir "${dir}/backups" "${dir}/public/scripts/extensions/third-party"

	# doins drops the source modes; npm ships these executable and
	# node_modules/.bin symlinks point at them.
	while IFS= read -r f; do
		fperms +x "${dir}/${f#"${WORKDIR}"/}"
	done < <(find "${WORKDIR}"/node_modules -type f -perm /111)

	DOCS=( LICENSE )
	einstalldocs
	newbin "${FILESDIR}"/sillytavern-launcher ${PN}
	systemd_douserunit "${FILESDIR}"/sillytavern.service
	newconfd "${FILESDIR}"/sillytavern-user.confd ${PN}
	newinitd "${FILESDIR}"/sillytavern-user.initd ${PN}
}
