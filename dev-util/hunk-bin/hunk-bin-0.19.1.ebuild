# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature wrapper

MY_PN="${PN%-bin}"
URI_PREFIX="https://github.com/modem-dev/hunk/releases/download/v${PV}"

DESCRIPTION="Review-first terminal diff viewer for agent-authored changesets"
HOMEPAGE="https://www.hunk.dev/ https://github.com/modem-dev/hunk"
SRC_URI="
	amd64? ( ${URI_PREFIX}/hunkdiff-linux-x64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( ${URI_PREFIX}/hunkdiff-linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
"

S="${WORKDIR}"

LICENSE="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2
	GPL-3 GPL-3+ gcc-runtime-library-exception-3.1 IJG ISC
	LGPL-2+ LGPL-2.1 MIT MPL-2.0 Unicode-3.0 ZLIB public-domain
	|| ( MIT-0 Unlicense )
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="
	+abi_x86_64
	cpu_flags_arm_asimd cpu_flags_arm_crc32
	cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_bmi1
	cpu_flags_x86_bmi2 cpu_flags_x86_f16c cpu_flags_x86_fma3
	cpu_flags_x86_popcnt cpu_flags_x86_sse3 cpu_flags_x86_sse4_1
	cpu_flags_x86_sse4_2 cpu_flags_x86_ssse3
"
REQUIRED_USE="
	amd64? (
		abi_x86_64
		cpu_flags_x86_avx cpu_flags_x86_avx2
		cpu_flags_x86_bmi1 cpu_flags_x86_bmi2
		cpu_flags_x86_f16c cpu_flags_x86_fma3
		cpu_flags_x86_popcnt cpu_flags_x86_sse3
		cpu_flags_x86_sse4_1 cpu_flags_x86_sse4_2
		cpu_flags_x86_ssse3
	)
	arm64? ( cpu_flags_arm_asimd cpu_flags_arm_crc32 )
"

RDEPEND=">=sys-libs/glibc-2.17"

RESTRICT="bindist mirror strip"
QA_PREBUILT="usr/libexec/${MY_PN}/${MY_PN}"

src_install() {
	local arch
	case ${ARCH} in
		amd64) arch=x64 ;;
		arm64) arch=arm64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	local src_dir="hunkdiff-linux-${arch}"
	local install_dir="/usr/libexec/${MY_PN}"

	exeinto "${install_dir}"
	doexe "${src_dir}/${MY_PN}"

	insinto "${install_dir}"
	doins -r "${src_dir}/skills"

	make_wrapper "${MY_PN}" \
		"env HUNK_DISABLE_UPDATE_NOTICE=1 ${EPREFIX}${install_dir}/${MY_PN}"
}

pkg_postinst() {
	optfeature "Git repository support" dev-vcs/git
	optfeature "Jujutsu repository support" dev-vcs/jj
}
