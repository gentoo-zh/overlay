# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The open source AI coding agent"
HOMEPAGE="https://opencode.ai https://github.com/anomalyco/opencode"

GITHUB_BASE="https://github.com/anomalyco/opencode/releases/download/v${PV}"
if [[ ${PV} == 9999 ]]; then
	PROPERTIES+=" live"
	GITHUB_BASE="https://github.com/anomalyco/opencode/releases/latest/download"
else
	SRC_URI="
		amd64? (
			cpu_flags_x86_avx2? (
				elibc_glibc? ( ${GITHUB_BASE}/opencode-linux-x64.tar.gz -> ${P}-amd64.tar.gz )
				elibc_musl? ( ${GITHUB_BASE}/opencode-linux-x64-musl.tar.gz -> ${P}-amd64-musl.tar.gz )
			)
			!cpu_flags_x86_avx2? (
				elibc_glibc? ( ${GITHUB_BASE}/opencode-linux-x64-baseline.tar.gz -> ${P}-amd64-baseline.tar.gz )
				elibc_musl? ( ${GITHUB_BASE}/opencode-linux-x64-baseline-musl.tar.gz -> ${P}-amd64-baseline-musl.tar.gz )
			)
		)
		arm64? (
			elibc_glibc? ( ${GITHUB_BASE}/opencode-linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
			elibc_musl? ( ${GITHUB_BASE}/opencode-linux-arm64-musl.tar.gz -> ${P}-arm64-musl.tar.gz )
		)
	"
	KEYWORDS="~amd64 ~arm64"
fi

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
IUSE="cpu_flags_x86_avx2"
RESTRICT="mirror strip"

[[ ${PV} == 9999 ]] && BDEPEND+=" net-misc/curl"

QA_PREBUILT="usr/bin/opencode"

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		local arch suffix=""
		case ${ARCH} in
			amd64) arch="x64" ;;
			arm64) arch="arm64" ;;
			*) die "Unsupported architecture: ${ARCH}" ;;
		esac
		[[ ${ARCH} == amd64 ]] && ! use cpu_flags_x86_avx2 && suffix+="-baseline"
		use elibc_musl && suffix+="-musl"

		local filename="opencode-linux-${arch}${suffix}.tar.gz"
		einfo "Downloading opencode latest release: ${filename}"
		curl -L -o "${WORKDIR}/${filename}" "${GITHUB_BASE}/${filename}" || die "Failed to download"
		cd "${WORKDIR}" || die
		tar -xzf "${filename}" || die "Failed to extract"
	else
		default_src_unpack
	fi
}

src_install() {
	dobin opencode
}
