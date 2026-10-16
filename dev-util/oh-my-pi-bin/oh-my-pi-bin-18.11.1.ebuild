# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="AI coding agent for the terminal"
HOMEPAGE="https://omp.sh https://github.com/can1357/oh-my-pi"
SRC_URI="
	amd64? (
		elibc_glibc? ( https://github.com/can1357/oh-my-pi/releases/download/v${PV}/omp-linux-x64 -> ${P}-amd64 )
		elibc_musl? ( https://github.com/can1357/oh-my-pi/releases/download/v${PV}/omp-linux-musl-x64 -> ${P}-amd64-musl )
	)
	arm64? (
		elibc_glibc? ( https://github.com/can1357/oh-my-pi/releases/download/v${PV}/omp-linux-arm64 -> ${P}-arm64 )
		elibc_musl? ( https://github.com/can1357/oh-my-pi/releases/download/v${PV}/omp-linux-musl-arm64 -> ${P}-arm64-musl )
	)
"
S="${WORKDIR}"

LICENSE="AGPL-3+ Apache-2.0 BSD CC-BY-4.0 MIT public-domain"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="
	cpu_flags_x86_popcnt cpu_flags_x86_sse3 cpu_flags_x86_sse4_1
	cpu_flags_x86_sse4_2 cpu_flags_x86_ssse3
"
REQUIRED_USE="
	^^ ( elibc_glibc elibc_musl )
	amd64? (
		cpu_flags_x86_popcnt cpu_flags_x86_sse3 cpu_flags_x86_sse4_1
		cpu_flags_x86_sse4_2 cpu_flags_x86_ssse3
	)
"
RESTRICT="bindist mirror strip"

RDEPEND="
	dev-vcs/git
	elibc_musl? ( sys-devel/gcc:* )
"

QA_PREBUILT="usr/libexec/oh-my-pi/omp"

src_unpack() {
	cp "${DISTDIR}/${A}" omp || die
	chmod +x omp || die
}

src_compile() {
	for sh in bash fish zsh; do
		./omp completions "${sh}" > "completion.${sh}" || die
	done
}

src_install() {
	exeinto /usr/libexec/oh-my-pi
	doexe omp

	sed -e "s|@EPREFIX@|${EPREFIX}|" "${FILESDIR}/omp" > "${T}/omp-wrapper" || die
	newbin "${T}/omp-wrapper" omp

	newbashcomp completion.bash omp
	newfishcomp completion.fish omp.fish
	newzshcomp completion.zsh _omp
}
