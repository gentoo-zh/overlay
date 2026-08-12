# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_SECURITY_UNSUPPORTED="1"
CJKTTY_PV="7.1.7"
K_GENPATCHES_VER="11"

inherit kernel-2 cjktty
detect_version
detect_arch

# kernel-2 truncates ${PN} at the first dash, so without this the sources land
# in linux-${OKV}-gentoo and collide with sys-kernel/gentoo-sources.
KV_FULL+="-cjk"
EXTRAVERSION+="-cjk"

DESCRIPTION="Gentoo kernel sources with the cjktty patch for CJK text on the console"
HOMEPAGE="https://github.com/gentoo-zh/cjktty-patches"
SRC_URI+=" ${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"
S="${WORKDIR}/linux-${KV_FULL}"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
IUSE+=" +cjk experimental"

pkg_setup() {
	ewarn ""
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "Report problems to https://github.com/gentoo-zh/overlay rather than"
	ewarn "Gentoo's bugzilla."
	ewarn ""

	kernel-2_pkg_setup
}

src_prepare() {
	cjktty_apply_patches
	kernel-2_src_prepare
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
