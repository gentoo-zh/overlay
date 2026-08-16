# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Cache-first DeepSeek coding agent for the terminal"
HOMEPAGE="https://github.com/esengine/DeepSeek-Reasonix"

GITHUB_BASE="https://github.com/esengine/DeepSeek-Reasonix/releases/download/v${PV}"
if [[ ${PV} == 9999 ]]; then
	PROPERTIES+=" live"
	GITHUB_BASE="https://github.com/esengine/DeepSeek-Reasonix/releases/latest/download"
else
	SRC_URI="
		amd64? ( ${GITHUB_BASE}/reasonix-linux-amd64.tar.gz -> ${P}-amd64.tar.gz )
		arm64? ( ${GITHUB_BASE}/reasonix-linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
	"
	KEYWORDS="~amd64 ~arm64"
fi

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
RESTRICT="mirror strip"

[[ ${PV} == 9999 ]] && BDEPEND+=" net-misc/curl"

QA_PREBUILT="usr/bin/reasonix"

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		local arch
		case ${ARCH} in
			amd64) arch="amd64" ;;
			arm64) arch="arm64" ;;
			*) die "Unsupported architecture: ${ARCH}" ;;
		esac

		local filename="reasonix-linux-${arch}.tar.gz"
		einfo "Downloading reasonix latest release: ${filename}"
		curl -L -o "${WORKDIR}/${filename}" "${GITHUB_BASE}/${filename}" || die "Failed to download"
		cd "${WORKDIR}" || die
		tar -xzf "${filename}" || die "Failed to extract"
	else
		default_src_unpack
	fi
}

src_install() {
	dobin reasonix
}
