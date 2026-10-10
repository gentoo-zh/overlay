# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit wrapper

DESCRIPTION="Fast, disk space efficient package manager"
HOMEPAGE="https://pnpm.io"
# Since 12.0.0 the CLI is a native executable, shipped in the per-platform packages
# @pnpm/exe.<os>-<arch>[-musl]. The pnpm package on npm is only a wrapper that
# installs one through a lifecycle script, or downloads one at run time.
URLPREFIX="https://registry.npmjs.org/@pnpm"
SRC_URI="
	amd64? (
		elibc_glibc? ( ${URLPREFIX}/exe.linux-x64/-/exe.linux-x64-${PV}.tgz -> ${P}-x64.tgz )
		elibc_musl? ( ${URLPREFIX}/exe.linux-x64-musl/-/exe.linux-x64-musl-${PV}.tgz -> ${P}-x64-musl.tgz )
	)
	arm64? (
		elibc_glibc? ( ${URLPREFIX}/exe.linux-arm64/-/exe.linux-arm64-${PV}.tgz -> ${P}-arm64.tgz )
		elibc_musl? ( ${URLPREFIX}/exe.linux-arm64-musl/-/exe.linux-arm64-musl-${PV}.tgz -> ${P}-arm64-musl.tgz )
	)
"
S="${WORKDIR}/package"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	!sys-apps/pnpm
	net-libs/nodejs
	elibc_glibc? (
		sys-devel/gcc:*
		sys-libs/glibc
	)
	elibc_musl? ( sys-libs/musl )
"

QA_PREBUILT="usr/bin/pnpm"

src_install() {
	dobin pnpm

	# The executable resolves its own path, so an alias cannot be a symlink. These
	# are the ones upstream ships as shell scripts in its wrapper package.
	make_wrapper pn pnpm
	make_wrapper pnpx "pnpm dlx"
	make_wrapper pnx "pnpm dlx"

	dodoc THIRD-PARTY-NOTICES.md
}
