# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="5"
K_SECURITY_UNSUPPORTED="1"

inherit check-reqs kernel-2
detect_version
detect_arch

CACHYOS_RELEASE="1"
CACHYOS_SERIES="${KV_MAJOR}.${KV_MINOR}"
CACHYOS_SRC="cachyos-${PV}-${CACHYOS_RELEASE}"
CACHYOS_PATCH_URI="https://raw.githubusercontent.com/CachyOS/kernel-patches/master/${CACHYOS_SERIES}"
EXTRAVERSION="-cachyos${CACHYOS_RELEASE}"
KV_FULL="${PV}${EXTRAVERSION}"
KV="${KV_FULL}"

DESCRIPTION="Linux kernel sources with CachyOS patches"
HOMEPAGE="
	https://cachyos.org
	https://github.com/CachyOS/linux
	https://github.com/CachyOS/kernel-patches
"
SRC_URI="
	https://github.com/CachyOS/linux/releases/download/${CACHYOS_SRC}/${CACHYOS_SRC}.tar.gz
		-> ${P}.tar.gz
	${GENPATCHES_URI}
	bore? (
		${CACHYOS_PATCH_URI}/sched/0001-bore-cachy.patch
			-> ${P}-0001-bore-cachy.patch
	)
	prjc? (
		${CACHYOS_PATCH_URI}/sched/0001-prjc-cachy.patch
			-> ${P}-0001-prjc-cachy.patch
	)
	prjc-lfbmq? (
		${CACHYOS_PATCH_URI}/sched/0001-prjc-cachy-lfbmq.patch
			-> ${P}-0001-prjc-cachy-lfbmq.patch
	)
	${CACHYOS_PATCH_URI}/misc/0001-acpi-call.patch
		-> ${P}-0001-acpi-call.patch
	${CACHYOS_PATCH_URI}/misc/0001-aufs-7.1-merge-v20260713.patch
		-> ${P}-0001-aufs.patch
	${CACHYOS_PATCH_URI}/misc/0001-clang-polly.patch
		-> ${P}-0001-clang-polly.patch
	${CACHYOS_PATCH_URI}/misc/0001-handheld.patch
		-> ${P}-0001-handheld.patch
	rt? (
		${CACHYOS_PATCH_URI}/misc/0001-rt-i915.patch
			-> ${P}-0001-rt-i915.patch
	)
	${CACHYOS_PATCH_URI}/misc/dkms-clang.patch
		-> ${P}-dkms-clang.patch
"
S="${WORKDIR}/linux-${KV_FULL}"

LICENSE="GPL-2"
KEYWORDS="~amd64"
IUSE="+bore prjc prjc-lfbmq rt thin"
REQUIRED_USE="?? ( bore prjc prjc-lfbmq )"
RDEPEND="
	thin? (
		llvm-core/clang
		llvm-core/lld
	)
"

apply_gentoo_genpatches() {
	local version_patch
	version_patch=$(find "${WORKDIR}" -maxdepth 1 -type f \
		-name "10*linux-${PV}.patch" -print -quit) || die
	[[ -n ${version_patch} ]] ||
		die "genpatches-${CACHYOS_SERIES}-${K_GENPATCHES_VER} is missing linux-${PV}.patch"

	find "${WORKDIR}" -maxdepth 1 -type f -name '10*linux*patch' -delete ||
		die "Failed to delete vanilla Linux update patches from genpatches"

	local gentoo_patches=( "${WORKDIR}"/*.patch )
	[[ -e ${gentoo_patches[0]} ]] ||
		die "No Gentoo genpatches left to apply"

	eapply "${gentoo_patches[@]}"
}

apply_cachyos_patches() {
	local cachyos_patches=()

	if use bore; then
		cachyos_patches+=( "${DISTDIR}/${P}-0001-bore-cachy.patch" )
	elif use prjc; then
		cachyos_patches+=( "${DISTDIR}/${P}-0001-prjc-cachy.patch" )
	elif use prjc-lfbmq; then
		cachyos_patches+=( "${DISTDIR}/${P}-0001-prjc-cachy-lfbmq.patch" )
	fi

	cachyos_patches+=(
		"${DISTDIR}/${P}-0001-acpi-call.patch"
		"${DISTDIR}/${P}-0001-aufs.patch"
		"${DISTDIR}/${P}-0001-clang-polly.patch"
		"${DISTDIR}/${P}-0001-handheld.patch"
	)

	use rt && cachyos_patches+=( "${DISTDIR}/${P}-0001-rt-i915.patch" )

	cachyos_patches+=( "${DISTDIR}/${P}-dkms-clang.patch" )

	eapply "${cachyos_patches[@]}"
}

pkg_pretend() {
	CHECKREQS_DISK_BUILD="4G"
	check-reqs_pkg_pretend
}

pkg_setup() {
	ewarn
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "For support, contact https://github.com/gentoo-zh/overlay or the CachyOS developers."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn

	kernel-2_pkg_setup
}

src_unpack() {
	local genpatches_type

	unpack "${P}.tar.gz"

	mv "${WORKDIR}/${CACHYOS_SRC}" "${S}" ||
		die "Failed to rename CachyOS source directory"

	for genpatches_type in ${K_WANT_GENPATCHES}; do
		unpack "genpatches-${CACHYOS_SERIES}-${K_GENPATCHES_VER}.${genpatches_type}.tar.xz"
	done
}

src_prepare() {
	if use thin; then
		cp "${FILESDIR}/${PN}-cachyos-thin.config" \
			"${S}/kernel/configs/cachyos-thin.config" || die
	fi

	rm -f "${S}/tools/testing/selftests/tc-testing/action-ebpf" || die

	apply_gentoo_genpatches
	apply_cachyos_patches
	eapply_user

	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" \
		"${S}/Makefile" || die
	sed -i -e 's:#export\tINSTALL_PATH:export\tINSTALL_PATH:' \
		"${S}/Makefile" || die
}

pkg_postinst() {
	kernel-2_pkg_postinst
	elog "For more information about CachyOS kernels, see https://wiki.cachyos.org/features/kernel/."
	if use thin; then
		elog "USE=thin installed kernel/configs/cachyos-thin.config."
		elog "To merge it into an existing kernel .config, run from /usr/src/linux-${KV_FULL}:"
		elog "  make LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld cachyos-thin.config olddefconfig"
		elog "Build the kernel with the same LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld arguments."
	fi
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
