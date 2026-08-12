# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
CJKTTY_PV="7.1.7"

inherit kernel-build toolchain-funcs verify-sig cjktty

BASE_P=linux-${PV%.*}
PATCH_PV=${PV%_p*}
PATCHSET=linux-gentoo-patches-7.1.6
# https://koji.fedoraproject.org/koji/packageinfo?packageID=8
# forked to git.gentoo.org:fork/fedora/kernel
CONFIG_VER=7.1.4-gentoo
GENTOO_CONFIG_P=gentoo-kernel-config-g19
SHA256SUM_DATE=20260809
# Debian kconfig commit from:
# https://salsa.debian.org/kernel-team/linux/-/tree/debian/latest/debian/
DEBIAN_COMMIT=2cba742ab58c8ee8ca715d02c0bdbf61ecbed1cc
DESCRIPTION="Distribution kernel with the cjktty patch for CJK text on the console"
HOMEPAGE="
	https://github.com/gentoo-zh/cjktty-patches
	https://wiki.gentoo.org/wiki/Project:Distribution_Kernel
	https://www.kernel.org/
"
SRC_URI+="
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${BASE_P}.tar.xz
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/patch-${PATCH_PV}.xz
	https://distfiles.gentoo.org/pub/proj/dist-kernel/patchsets/$(ver_cut 1-2)/${PATCHSET}.tar.xz
	https://gitweb.gentoo.org/proj/dist-kernel/gentoo-kernel-config.git/snapshot/${GENTOO_CONFIG_P}.tar.bz2
	https://gitweb.gentoo.org/fork/fedora/kernel.git/snapshot/kernel-${CONFIG_VER}.tar.bz2
	https://salsa.debian.org/kernel-team/linux/-/archive/${DEBIAN_COMMIT}/linux-${DEBIAN_COMMIT}.tar.bz2
	verify-sig? (
		https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/sha256sums.asc
			-> linux-$(ver_cut 1).x-sha256sums-${SHA256SUM_DATE}.asc
	)
"
S=${WORKDIR}/${BASE_P}

KEYWORDS="~amd64"
IUSE+=" +cjk debug hardened"

BDEPEND="
	debug? ( dev-util/pahole )
	verify-sig? ( >=sec-keys/openpgp-keys-kernel-20250702 )
"
PDEPEND="
	=virtual/dist-kernel-${PV}-r100
"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/kernel.org.asc

src_unpack() {
	if use verify-sig; then
		cd "${DISTDIR}" || die
		verify-sig_verify_signed_checksums \
			"linux-$(ver_cut 1).x-sha256sums-${SHA256SUM_DATE}.asc" \
			sha256 "${BASE_P}.tar.xz patch-${PATCH_PV}.xz"
		cd "${WORKDIR}" || die
	fi

	default
}

src_prepare() {
	local patch
	eapply "${WORKDIR}/patch-${PATCH_PV}"
	eapply "${WORKDIR}/${PATCHSET}"
	cjktty_apply_patches

	default

	# add Gentoo patchset version
	local extraversion=${PV#${PATCH_PV}}
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${extraversion/_/-}:" Makefile || die

	local biendian=false

	# prepare the default config
	case ${ARCH} in
		hppa | mips)
			> .config || die
		;;
		alpha)
			cp "${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/config" .config || die
			merge_configs+=(
				"${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/alpha/config" \
				"${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/alpha/config.alpha-smp"
			)
			;;
		amd64)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-x86_64-fedora.config" .config || die
			;;
		arm)
			cp "${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/config" .config || die
			merge_configs+=(
				"${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/armhf/config" \
				"${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/armhf/config.armmp-lpae"
			)
			;;
		arm64)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-aarch64-fedora.config" .config || die
			biendian=true
			;;
		loong)
			cp "${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/config" .config || die
			merge_configs+=(
				"${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/loong64/config"
			)
			;;
		m68k)
			cp "${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/config" .config || die
			merge_configs+=(
				"${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/m68k/config"
			)
			;;
		ppc)
			cp "${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/config" .config || die
			merge_configs+=(
				"${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/powerpc/config.powerpc"
			)
			;;
		ppc64)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-ppc64le-fedora.config" .config || die
			biendian=true
			;;
		riscv)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-riscv64-fedora.config" .config || die
			;;
		s390)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-s390x-fedora.config" .config || die
			;;
		sparc)
			cp "${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/config" .config || die
			merge_configs+=(
				"${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/sparc64/config.sparc64" \
				"${WORKDIR}/linux-${DEBIAN_COMMIT}/debian/config/sparc64/config.sparc64-smp"
			)
			;;
		x86)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-i686-fedora.config" .config || die
			;;
		*)
			die "Unsupported arch ${ARCH}"
			;;
	esac

	local myversion="-gentoo-dist"
	use cjk && myversion="-gentoo-cjk-dist"
	use hardened && myversion+="-hardened"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die
	local dist_conf_path="${WORKDIR}/${GENTOO_CONFIG_P}"

	local merge_configs=(
		"${T}"/version.config
		"${dist_conf_path}"/base.config
		"${dist_conf_path}"/6.12+.config
	)
	if use cjk; then
		local cjk32_config='# CONFIG_FONT_CJK_32x32 is not set'
		use cjk32 && cjk32_config='CONFIG_FONT_CJK_32x32=y'
		cat > "${T}"/cjk.config <<-EOF || die
			CONFIG_FONTS=y
			CONFIG_FONT_CJK_16x16=y
			${cjk32_config}
		EOF
		merge_configs+=( "${T}"/cjk.config )
	fi
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)
	if use hardened; then
		merge_configs+=( "${dist_conf_path}"/hardened-base.config )

		tc-is-gcc && merge_configs+=( "${dist_conf_path}"/hardened-gcc-plugins.config )

		if [[ -f "${dist_conf_path}/hardened-${ARCH}.config" ]]; then
			merge_configs+=( "${dist_conf_path}/hardened-${ARCH}.config" )
		fi
	fi

	# this covers ppc64 and aarch64_be only for now
	if [[ ${biendian} == true && $(tc-endian) == big ]]; then
		merge_configs+=( "${dist_conf_path}/big-endian.config" )
	fi

	use secureboot && merge_configs+=(
		"${dist_conf_path}/secureboot.config"
		"${dist_conf_path}/zboot.config"
	)

	kernel-build_merge_configs "${merge_configs[@]}"
}

pkg_postinst() {
	kernel-build_pkg_postinst

	ewarn ""
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "Report problems to https://github.com/gentoo-zh/overlay rather than"
	ewarn "Gentoo's bugzilla."
	ewarn ""
}
