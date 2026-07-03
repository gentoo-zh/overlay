# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/_p/-}"

DESCRIPTION="A proxy using Chromium's network stack to camouflage traffic"
HOMEPAGE="https://github.com/klzgrad/naiveproxy"
DIST_URI="https://github.com/klzgrad/naiveproxy/releases/download/v${MY_PV}/naiveproxy-v${MY_PV}-linux"
SRC_URI="
	amd64? ( ${DIST_URI}-x64.tar.xz )
	arm? ( ${DIST_URI}-arm.tar.xz )
	arm64? ( ${DIST_URI}-arm64.tar.xz )
	mips? (
		abi_mips_o32? ( ${DIST_URI}-mipsel.tar.xz )
		abi_mips_n64? ( ${DIST_URI}-mips64el.tar.xz )
	)
	riscv? ( ${DIST_URI}-riscv64.tar.xz )
	x86? ( ${DIST_URI}-x86.tar.xz )
"

case ${ARCH} in
	amd64)	MY_ARCH=x64;;
	mips)	if use abi_mips_o32; then
			MY_ARCH=mipsel
		elif use abi_mips_n64; then
			MY_ARCH=mips64el
		fi;;
	riscv)	MY_ARCH=riscv64;;
	*)	MY_ARCH=${ARCH};;
esac

S="${WORKDIR}/naiveproxy-v${MY_PV}-linux-${MY_ARCH}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm ~arm64 ~mips ~riscv ~x86"
IUSE="abi_mips_n64 abi_mips_o32 big-endian"
REQUIRED_USE="mips? ( !big-endian || ( abi_mips_n64 abi_mips_o32 ) )"

QA_PREBUILT="
	/opt/naiveproxy/naive
"

src_install() {
	insinto /opt/naiveproxy
	doins config.json naive
	dodoc USAGE.txt
	fperms +x /opt/naiveproxy/naive
	dosym -r /opt/naiveproxy/naive /usr/bin/naive
}
