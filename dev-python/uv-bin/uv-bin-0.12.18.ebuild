# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit unpacker
DESCRIPTION="An extremely fast Python package and project manager, written in Rust"
HOMEPAGE="https://github.com/astral-sh/uv"
URLPREFIX="https://github.com/astral-sh/uv/releases/download"
SRC_URI="
	amd64? (
		elibc_glibc? ( ${URLPREFIX}/${PV}/uv-x86_64-unknown-linux-gnu.tar.gz -> ${P}-x86_64-unknown-linux-gnu.tar.gz )
		elibc_musl? ( ${URLPREFIX}/${PV}/uv-x86_64-unknown-linux-musl.tar.gz  -> ${P}-x86_64-unknown-linux-musl.tar.gz )
	)
"

S="${WORKDIR}"
LICENSE="|| ( Apache-2.0 MIT )"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"
RDEPEND="
	!dev-python/uv
	elibc_glibc? (
		sys-devel/gcc:*
		sys-libs/glibc
	)
	elibc_musl? ( sys-libs/musl )
"

QA_PREBUILT="usr/bin/uv usr/bin/uvx"

src_install() {
	if use elibc_glibc ; then
		dir="uv-x86_64-unknown-linux-gnu"
	elif use elibc_musl ; then
		dir="uv-x86_64-unknown-linux-musl"
	else
		die "Unsupported libc"
	fi

	dobin "${dir}/uv" "${dir}/uvx"
}
