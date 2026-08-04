# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=(19 20 21 22)

inherit kernel-build toolchain-funcs llvm-r2

MY_P=linux-${PV%.*}
# Note: to bump xanmod, check PATCHSET in sys-kernel/gentoo-kernel
PATCHSET=linux-gentoo-patches-${PV}
XV="1"

DESCRIPTION="XanMod kernel built with Gentoo patches and cjktty"
HOMEPAGE="
	https://www.kernel.org/
	https://xanmod.org/
"
SRC_URI+="
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${MY_P}.tar.xz
	https://distfiles.gentoo.org/pub/proj/dist-kernel/patchsets/$(ver_cut 1-2)/${PATCHSET}.tar.xz
	https://downloads.sourceforge.net/project/xanmod/releases/main/${PV}-xanmod1/patch-${PV}-xanmod1.xz"
S=${WORKDIR}/${MY_P}

LICENSE="GPL-2"
KEYWORDS="~amd64"
IUSE="clang debug"

BDEPEND="
	clang? (
		$(llvm_gen_dep '
			llvm-core/llvm:${LLVM_SLOT}
			llvm-core/clang:${LLVM_SLOT}
			llvm-core/lld:${LLVM_SLOT}
		')
	)
	sys-libs/binutils-libs
"

PDEPEND="
	=virtual/dist-kernel-${PV}-r100
"

QA_FLAGS_IGNORED="usr/src/linux-.*/scripts/gcc-plugins/.*.so usr/src/linux-.*/certs/.*.o"

pkg_setup() {
	ewarn ""
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "You have to configure the kernel by yourself."
	ewarn "Generally emerge this package using default config will fail to boot."
	ewarn "If you need support, please contact the ${HOMEPAGE} or maintainer directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn ""
	if use clang && ! tc-is-clang; then
		export LLVM_IAS=1
		export LLVM=1
		export CC=clang
		export LD=ld.lld
		export AR=llvm-ar
		export NM=llvm-nm
		export OBJCOPY=llvm-objcopy
		export OBJDUMP=llvm-objdump
		export READELF=llvm-readelf
		export STRIP=llvm-strip
	else
		tc-export CXX CC
	fi

}

src_prepare() {
	local PATCHES=(
		# xanmod patches
		"${WORKDIR}"/patch-${PV}-xanmod${XV}
		# genpatches
		"${WORKDIR}/${PATCHSET}"/*.patch
	)
	default

	# prepare the default config
	case ${ARCH} in
	amd64)
		cp "${S}/CONFIGS/x86_64/config" .config || die
		XV="${XV}-x64v3"
		;;
	*)
		die "Unsupported arch ${ARCH}"
		;;
	esac

	echo "CONFIG_MODPROBE_PATH=\"/sbin/modprobe\"" >"${T}"/modprobe.config || die

	local merge_configs=(
		"${T}"/modprobe.config
	)

	kernel-build_merge_configs "${merge_configs[@]}"
	# delete localversion
	rm "${S}/localversion" || die
}
