# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"
URI_PREFIX="https://github.com/ogulcancelik/${MY_PN}/releases/download/v${PV}"

DESCRIPTION="Terminal workspace manager for AI coding agents"
HOMEPAGE="https://herdr.dev https://github.com/ogulcancelik/herdr"
SRC_URI="
	amd64? ( ${URI_PREFIX}/${MY_PN}-linux-x86_64 -> ${P}-amd64 )
	arm64? ( ${URI_PREFIX}/${MY_PN}-linux-aarch64 -> ${P}-arm64 )
"

S="${WORKDIR}"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="mirror strip"
QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	local bin
	case ${ARCH} in
		amd64) bin="${P}-amd64" ;;
		arm64) bin="${P}-arm64" ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	newbin "${DISTDIR}/${bin}" "${MY_PN}"
}
