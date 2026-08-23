# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_P="biliupR-v${PV}"
URLPREFIX="https://github.com/biliup/biliup/releases/download/v${PV}"

DESCRIPTION="Command line tool to record streams and upload videos to bilibili"
HOMEPAGE="https://github.com/biliup/biliup"
SRC_URI="
	amd64? (
		elibc_glibc? ( ${URLPREFIX}/${MY_P}-x86_64-linux.tar.xz )
		elibc_musl? ( ${URLPREFIX}/${MY_P}-x86_64-linux-musl.tar.xz )
	)
	arm64? ( elibc_glibc? ( ${URLPREFIX}/${MY_P}-aarch64-linux.tar.xz ) )
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	elibc_glibc? (
		sys-devel/gcc:*
		sys-libs/glibc
	)
"

QA_PREBUILT="usr/bin/biliup"

src_install() {
	local dir
	if use amd64 && use elibc_glibc; then
		dir="${MY_P}-x86_64-linux"
	elif use amd64 && use elibc_musl; then
		dir="${MY_P}-x86_64-linux-musl"
	elif use arm64 && use elibc_glibc; then
		dir="${MY_P}-aarch64-linux"
	else
		die "upstream ships no prebuilt binary for this arch and libc"
	fi

	dobin "${dir}/biliup"
}
