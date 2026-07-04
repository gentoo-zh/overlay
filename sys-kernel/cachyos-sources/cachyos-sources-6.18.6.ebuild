# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="8"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"

inherit kernel-2
detect_version
detect_arch

MY_KV="${KV_MAJOR}.${KV_MINOR}"
AUFS_V="20251208"

DESCRIPTION="Full Cachyos sources including the Gentoo patchset for the ${MY_KV} kernel tree"
HOMEPAGE="https://cachyos.org"
CACHYOS_URI="https://github.com/blackteahamburger/gentoo-CachyOS-kernel-patches-tarball/releases/download/${PV}/${P}.tar.gz"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI} ${CACHYOS_URI}"
KEYWORDS="~amd64"
IUSE="amd-pstate asus autofdo bbr3 +cachy crypto +fixes hdmi intel-pstate sched-ext t2 +bore prjc prjc-lfbmq polly rt-i915 dkms-clang aufs deckify"
REQUIRED_USE="?? ( bore prjc prjc-lfbmq )"

src_unpack() {
	unpack "${P}.tar.gz"
	kernel-2_src_unpack
}

src_prepare() {
	local i=1
	for flag in amd-pstate asus autofdo bbr3 cachy crypto fixes hdmi intel-pstate sched-ext t2; do
		use ${flag} && eapply "${WORKDIR}/${P}/$(printf '%04d' ${i})-${flag}.patch"
		((i++))
	done
	use bore && eapply "${WORKDIR}/${P}/sched/0001-bore-cachy.patch"
	use prjc && eapply "${WORKDIR}/${P}/sched/0001-prjc-cachy.patch"
	use prjc-lfbmq && eapply "${WORKDIR}/${P}/sched/0001-prjc-lfbmq.patch"
	use polly && eapply "${WORKDIR}/${P}/misc/0001-clang-polly.patch"
	use rt-i915 && eapply "${WORKDIR}/${P}/misc/0001-rt-i915.patch"
	use dkms-clang && eapply "${WORKDIR}/${P}/misc/dkms-clang.patch"
	use aufs && eapply "${WORKDIR}/${P}/misc/0001-aufs-${MY_KV}-merge-v${AUFS_V}.patch"
	if use deckify; then
		eapply "${WORKDIR}/${P}/misc/0001-acpi-call.patch"
		eapply "${WORKDIR}/${P}/misc/0001-handheld.patch"
	fi

	kernel-2_src_prepare
}

pkg_setup() {
	ewarn
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please contact https://github.com/gentoo-zh/overlay and ${HOMEPAGE} directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn
	kernel-2_pkg_setup
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"

	if use polly && ! has_version llvm-core/clang-runtime[polly]; then
		einfo "You need to enable polly use flag for llvm-core/clang-runtime to build the kernel with polly"
	fi
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
