# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras experimental"
K_SECURITY_UNSUPPORTED="1"
CJKTTY_PV="6.12.104"
K_GENPATCHES_VER="117"

inherit check-reqs kernel-2 cjktty
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

pkg_pretend() {
	CHECKREQS_DISK_BUILD="4G"
	check-reqs_pkg_pretend
}

src_prepare() {
	cjktty_apply_patches
	kernel-2_src_prepare
	rm "${S}/tools/testing/selftests/tc-testing/action-ebpf"
}

pkg_setup() {
	ewarn ""
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "Do *not* open bugs in Gentoo's bugzilla. Report problems to"
	ewarn "https://github.com/gentoo-zh/overlay. Thank you."
	ewarn ""

	kernel-2_pkg_setup
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
