# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

ETYPE="sources"
EXTRAVERSION="-cachyos"
K_NOSETEXTRAVERSION="1"

# Pin patch, config, and downstream rebase inputs so Manifest checks cover
# exact immutable GitHub bytes.
CACHYOS_PATCHES_COMMIT="a40b85abdcb9f4ba653e2e1ea89d3d1f0cf563ba"
CACHYOS_CONFIGS_COMMIT="b165d04e2c7ccfa5f5448957ccb9d61754f20e6e"
CACHYOS_REBASE_COMMIT="127c70edf723c471e99963e2a61923e2025feeda"
# Source tag is cachyos-6.18.48-2; downstream patch updates do not change CPV.
CACHYOS_PR="2"

# Genpatches support - apply base and extras patches on top of CachyOS tarball
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="55"

# Exclude kernel version upgrade patches (10xx_linux-*.patch)
# CachyOS tarball already includes the latest point release
# The CachyOS pre-patched tarball already contains genpatch 2700.
UNIPATCH_EXCLUDE="10 2700"

# CachyOS tarball already includes the point release, while we skip Gentoo's
# 10xx point-release genpatches above.
K_NO_VERSION_CHECK="1"
K_SECURITY_UNSUPPORTED="1"

ZFS_COMMIT="71a9f9578616a90c3c14bb59629fb4d31bfd68d1"
CJKTTY_PV="6.18.45"
CKV="$(ver_cut 1-3)"
CACHYOS_SERIES="$(ver_cut 1-2)"
CACHYOS_PATCH_URI="https://github.com/CachyOS/kernel-patches/raw/${CACHYOS_PATCHES_COMMIT}/${CACHYOS_SERIES}"
CACHYOS_CONFIG_URI="https://github.com/CachyOS/linux-cachyos/raw/${CACHYOS_CONFIGS_COMMIT}"
CACHYOS_REBASE_URI="https://github.com/Szowisz/CachyOS-kernels/raw/${CACHYOS_REBASE_COMMIT}/sys-kernel/cachyos-sources/files/6.18.48-r2"
CACHYOS_PATCH_PREFIX="cachyos-kernel-patches-${CACHYOS_PATCHES_COMMIT}-${CACHYOS_SERIES}"
CACHYOS_CONFIG_PREFIX="linux-cachyos-lts-${CACHYOS_CONFIGS_COMMIT}"
CACHYOS_REBASE_PREFIX="cachyos-kernels-${CACHYOS_REBASE_COMMIT}-6.18.48"

inherit check-reqs kernel-2 optfeature cjktty

# make sure kernel-2 know right version without guess
detect_version

# Override KERNEL_URI to use CachyOS pre-patched tarball
KERNEL_URI="https://github.com/CachyOS/linux/releases/download/cachyos-${CKV}-${CACHYOS_PR}/cachyos-${CKV}-${CACHYOS_PR}.tar.gz"

# S is set by detect_version to linux-${KV_FULL}, we'll rename the directory in src_unpack
# Disable kernel-2.eclass's automatic kernel.org incremental patches
UNIPATCH_LIST_DEFAULT=""

DESCRIPTION="Archlinux kernel based on different schedulers and performance improvements"
HOMEPAGE="
	https://cachyos.org
	https://github.com/CachyOS/linux-cachyos
	https://github.com/CachyOS/linux
	https://github.com/CachyOS/kernel-patches
	https://github.com/gentoo-zh/cjktty-patches
"
SRC_URI+="
	${KERNEL_URI}
	${GENPATCHES_URI}
	${CACHYOS_CONFIG_URI}/linux-cachyos-lts/config
		-> ${CACHYOS_CONFIG_PREFIX}-config
	bore? (
		${CACHYOS_REBASE_URI}/sched/0001-bore-cachy.patch
			-> ${CACHYOS_REBASE_PREFIX}-bore.patch
	)
	bmq? (
		${CACHYOS_REBASE_URI}/sched/0001-prjc-cachy.patch
			-> ${CACHYOS_REBASE_PREFIX}-prjc.patch
	)
	cachyos-hardened? (
		${CACHYOS_REBASE_URI}/sched/0001-bore-cachy.patch
			-> ${CACHYOS_REBASE_PREFIX}-bore.patch
		${CACHYOS_REBASE_URI}/misc/0001-hardened.patch
			-> ${CACHYOS_REBASE_PREFIX}-hardened.patch
		${CACHYOS_REBASE_URI}/misc/0002-hardened-protected-fifos-regular-2.patch
			-> ${CACHYOS_REBASE_PREFIX}-hardened-sysctl.patch
	)
	rt? (
		${CACHYOS_PATCH_URI}/misc/0001-rt-i915.patch
			-> ${CACHYOS_PATCH_PREFIX}-rt-i915.patch
	)
	rt-bore? (
		${CACHYOS_REBASE_URI}/sched/0001-bore-cachy.patch
			-> ${CACHYOS_REBASE_PREFIX}-bore.patch
		${CACHYOS_PATCH_URI}/misc/0001-rt-i915.patch
			-> ${CACHYOS_PATCH_PREFIX}-rt-i915.patch
	)
	${CACHYOS_PATCH_URI}/misc/dkms-clang.patch
		-> ${CACHYOS_PATCH_PREFIX}-dkms-clang.patch
	kernel-builtin-zfs? (
		https://github.com/cachyos/zfs/archive/${ZFS_COMMIT}.tar.gz
			-> zfs-${ZFS_COMMIT}.tar.gz
	)
"

LICENSE+=" kernel-builtin-zfs? ( BSD-2 CDDL GPL-3 MIT )"
KEYWORDS="~amd64"
IUSE+="
	bore bmq cachyos-hardened rt rt-bore +eevdf
	kcfi cjk
	autofdo propeller
	llvm-lto-thin llvm-lto-full llvm-lto-thin-dist +llvm-lto-none
	kernel-builtin-zfs
	hz-ticks-100 hz-ticks-250 hz-ticks-300 hz-ticks-500 hz-ticks-600 hz-ticks-750 +hz-ticks-1000
	+per-gov tickrate-periodic tickrate-idle +tickrate-full +preempt-full preempt-lazy
	+o3 os debug +bbr3
	+hugepage-always hugepage-madvise
	mgeneric mgeneric-v1 mgeneric-v2 mgeneric-v3 mgeneric-v4
	+mnative mzen4
"

# OpenZFS does not support Clang CFI: https://github.com/openzfs/zfs/issues/15911
# The linux-cachyos-lts PKGBUILD exposes BORE, BMQ, hardened, EEVDF,
# PREEMPT_RT, and RT-BORE. Its moving 6.18 kernel-patches inputs were stale for
# cachyos-6.18.48-2, so commit-pinned exact-version rebases preserve those
# advertised variants without encoding downstream patch iterations in CPV.
# The default upstream "cachyos" selector is documented as EEVDF and downloads
# no scheduler patch; it is represented by the default eevdf USE selection.
# Deckify, MuQSS, and BMQ-LFBMQ are absent from the current LTS PKGBUILD.
REQUIRED_USE+="
	^^ ( bore bmq cachyos-hardened rt rt-bore eevdf )
	propeller? ( !llvm-lto-full !llvm-lto-none )
	autofdo? ( || ( llvm-lto-thin llvm-lto-full llvm-lto-thin-dist ) )
	kernel-builtin-zfs? ( !kcfi )
	^^ ( llvm-lto-thin llvm-lto-full llvm-lto-thin-dist llvm-lto-none )
	^^ ( hz-ticks-100 hz-ticks-250 hz-ticks-300 hz-ticks-500 hz-ticks-600 hz-ticks-750 hz-ticks-1000 )
	^^ ( tickrate-periodic tickrate-idle tickrate-full )
	^^ ( preempt-full preempt-lazy )
	?? ( o3 os debug )
	^^ ( hugepage-always hugepage-madvise )
	?? ( mgeneric mgeneric-v1 mgeneric-v2 mgeneric-v3 mgeneric-v4 mnative mzen4 )
"

RDEPEND+="
	dev-util/pahole
	autofdo? ( dev-util/perf[libpfm] )
	!llvm-lto-none? (
		llvm-core/clang
		llvm-core/lld
	)
	llvm-lto-none? (
		kernel-builtin-zfs? (
			llvm-core/clang
			llvm-core/lld
		)
		!kernel-builtin-zfs? (
			propeller? (
				llvm-core/clang
				llvm-core/lld
			)
			!propeller? (
				kcfi? ( llvm-core/clang )
			)
		)
	)
"

_set_hztick_rate() {
	local hertz=$1

	if [[ ${hertz} == 300 ]]; then
		scripts/config -e HZ_300 --set-val HZ 300 || die
	else
		scripts/config -d HZ_300 -e "HZ_${hertz}" --set-val HZ "${hertz}" || die
	fi
}

# Override kernel-2.eclass universal_unpack to handle CachyOS pre-patched tarball
universal_unpack() {
	cd "${WORKDIR}" || die
	unpack "cachyos-${CKV}-${CACHYOS_PR}.tar.gz"
	mv "cachyos-${CKV}-${CACHYOS_PR}" "${S}" || die
	cd "${S}" || die
}

src_unpack() {
	# Use kernel-2.eclass src_unpack (will call our overridden universal_unpack)
	kernel-2_src_unpack

	if use kernel-builtin-zfs; then
		### Push ZFS to linux
		unpack "zfs-${ZFS_COMMIT}.tar.gz"
		mv "zfs-${ZFS_COMMIT}" zfs || die
		cp "${FILESDIR}/kernel-build.sh" . || die
		chmod +x kernel-build.sh || die
	fi
}

src_prepare() {
	local patches_prefix="${DISTDIR}/${CACHYOS_PATCH_PREFIX}"
	local configs_prefix="${DISTDIR}/${CACHYOS_CONFIG_PREFIX}"
	local rebases_prefix="${DISTDIR}/${CACHYOS_REBASE_PREFIX}"
	local march_flag march=""
	local -a march_flags=(
		mgeneric mgeneric-v1 mgeneric-v2 mgeneric-v3 mgeneric-v4 mnative mzen4
	)

	# Fix AutoFDO/Propeller support for LTO_CLANG_THIN_DIST
	# The distributed ThinLTO patch by Rong Xu (xur@google.com) did not update
	# Makefile.autofdo and Makefile.propeller for CONFIG_LTO_CLANG_THIN_DIST.
	# RFC: https://discourse.llvm.org/t/rfc-distributed-thinlto-build-for-kernel/85934
	# Original patch: https://github.com/xur-llvm/linux/commit/d970eaf7d90863e7f2ea7bd0c8fe44d4602c2e86
	# Upstream mail: https://lore.kernel.org/linux-kbuild/20250420010214.1963979-1-xur@google.com/
	# Fix suggested by marioroy: https://discourse.llvm.org/t/rfc-distributed-thinlto-build-for-kernel/85934/5
	# https://github.com/Szowisz/CachyOS-kernels/issues/35
	eapply "${FILESDIR}/6.19.0/misc/0002-fix-autofdo-propeller-lto-thin-dist.patch"

	if use bore || use rt-bore || use cachyos-hardened; then
		eapply --fuzz=0 -- "${rebases_prefix}-bore.patch"
	elif use bmq; then
		eapply --fuzz=0 -- "${rebases_prefix}-prjc.patch"
	fi

	if use cachyos-hardened; then
		eapply --fuzz=0 -- "${rebases_prefix}-hardened.patch"
		eapply --fuzz=0 -- "${rebases_prefix}-hardened-sysctl.patch"
	fi

	if use rt; then
		eapply "${patches_prefix}-rt-i915.patch"
	elif use rt-bore; then
		eapply "${patches_prefix}-rt-i915.patch"
	fi

	cp "${configs_prefix}-config" .config || die

	if use kcfi || use propeller || ! use llvm-lto-none; then
		eapply "${patches_prefix}-dkms-clang.patch"
	fi

	cjktty_apply_patches
	eapply_user

	# CachyOS ships a prebuilt BPF object in its source tarball.
	rm -f tools/testing/selftests/tc-testing/action-ebpf || die

	# Keep source directory and kernel release on kernel-2.eclass's revision suffix.
	echo "${KV_FULL#${PV}}" > localversion.20-pkgname || die

	scripts/config -e CACHY || die

	if use cjk; then
		scripts/config --keep-case -e FONT_CJK_16x16 || die
		use cjk32 && { scripts/config --keep-case -e FONT_CJK_32x32 || die; }
	fi

	if use bore || use cachyos-hardened; then
		scripts/config -e SCHED_BORE || die
	elif use bmq; then
		scripts/config -e SCHED_ALT -e SCHED_BMQ || die
	elif use rt; then
		scripts/config -e PREEMPT_RT || die
	elif use rt-bore; then
		scripts/config -e SCHED_BORE -e PREEMPT_RT || die
	fi

	### Enable KCFI
	if use kcfi; then
		scripts/config -e ARCH_SUPPORTS_CFI_CLANG -e CFI -e CFI_CLANG -e CFI_AUTO_DEFAULT || die
	else
		# https://github.com/openzfs/zfs/issues/15911
		scripts/config -d CFI -d CFI_CLANG -e CFI_PERMISSIVE || die
	fi

	### Select LLVM level
	if use llvm-lto-thin; then
		scripts/config -d LTO_NONE -d LTO_CLANG_FULL -d LTO_CLANG_THIN_DIST \
			-e LTO_CLANG_THIN || die
	elif use llvm-lto-thin-dist; then
		scripts/config -d LTO_NONE -d LTO_CLANG_FULL -d LTO_CLANG_THIN \
			-e LTO_CLANG_THIN_DIST || die
	elif use llvm-lto-full; then
		scripts/config -d LTO_NONE -d LTO_CLANG_THIN -d LTO_CLANG_THIN_DIST \
			-e LTO_CLANG_FULL || die
	elif use llvm-lto-none; then
		scripts/config -d LTO_CLANG_FULL -d LTO_CLANG_THIN -d LTO_CLANG_THIN_DIST \
			-e LTO_NONE || die
	fi

	if use llvm-lto-none; then
		scripts/config --set-str DRM_PANIC_SCREEN qr_code -e DRM_PANIC_SCREEN_QR_CODE \
			--set-str DRM_PANIC_SCREEN_QR_CODE_URL "https://panic.archlinux.org/panic_report#" \
			--set-val DRM_PANIC_SCREEN_QR_VERSION 40 || die
	fi

	if use hz-ticks-100; then
		_set_hztick_rate 100
	elif use hz-ticks-250; then
		_set_hztick_rate 250
	elif use hz-ticks-300; then
		_set_hztick_rate 300
	elif use hz-ticks-500; then
		_set_hztick_rate 500
	elif use hz-ticks-600; then
		_set_hztick_rate 600
	elif use hz-ticks-750; then
		_set_hztick_rate 750
	elif use hz-ticks-1000; then
		_set_hztick_rate 1000
	else
		die "Invalid HZ_TICKS USE flag"
	fi

	if use per-gov; then
		scripts/config -d CPU_FREQ_DEFAULT_GOV_SCHEDUTIL -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE || die
	fi

	if use tickrate-periodic; then
		scripts/config -d NO_HZ_IDLE -d NO_HZ_FULL -d NO_HZ -d NO_HZ_COMMON -e HZ_PERIODIC || die
	elif use tickrate-idle; then
		scripts/config -d HZ_PERIODIC -d NO_HZ_FULL -e NO_HZ_IDLE -e NO_HZ -e NO_HZ_COMMON || die
	elif use tickrate-full; then
		scripts/config \
			-d HZ_PERIODIC -d NO_HZ_IDLE -d CONTEXT_TRACKING_FORCE \
			-e NO_HZ_FULL_NODEF -e NO_HZ_FULL -e NO_HZ -e NO_HZ_COMMON \
			-e CONTEXT_TRACKING || die
	fi

	if ! use rt && ! use rt-bore; then
		scripts/config -e PREEMPT_DYNAMIC || die
		if use preempt-full; then
			scripts/config -e PREEMPT -d PREEMPT_LAZY || die
		elif use preempt-lazy; then
			scripts/config -d PREEMPT -e PREEMPT_LAZY || die
		fi
	fi

	if use o3; then
		scripts/config -d CC_OPTIMIZE_FOR_PERFORMANCE -e CC_OPTIMIZE_FOR_PERFORMANCE_O3 || die
	elif use os; then
		scripts/config -d CC_OPTIMIZE_FOR_PERFORMANCE -e CC_OPTIMIZE_FOR_SIZE || die
	elif use debug; then
		scripts/config \
			-d CC_OPTIMIZE_FOR_PERFORMANCE \
			-d CC_OPTIMIZE_FOR_PERFORMANCE_O3 \
			-e CC_OPTIMIZE_FOR_SIZE \
			-d SLUB_DEBUG \
			-d PM_DEBUG \
			-d PM_ADVANCED_DEBUG \
			-d PM_SLEEP_DEBUG \
			-d ACPI_DEBUG \
			-d LATENCYTOP \
			-d SCHED_DEBUG \
			-d DEBUG_PREEMPT || die
	fi

	if use bbr3; then
		# Upstream linux-cachyos `_tcp_bbr3` still enables vanilla BBR.
		# Enable real BBR3 as default, keep vanilla BBR as a module so both
		# are not built into vmlinux (duplicate tcp_bbr_check_kfunc_ids
		# BTF set, Szowisz/CachyOS-kernels#53).
		scripts/config -m TCP_CONG_CUBIC \
			-d DEFAULT_CUBIC \
			-m TCP_CONG_BBR \
			-d DEFAULT_BBR \
			-e TCP_CONG_BBR3 \
			-e DEFAULT_BBR3 \
			--set-str DEFAULT_TCP_CONG bbr3 \
			-m NET_SCH_FQ_CODEL \
			-e NET_SCH_FQ \
			-d DEFAULT_FQ_CODEL \
			-e DEFAULT_FQ || die
	fi

	if use hugepage-always; then
		scripts/config -d TRANSPARENT_HUGEPAGE_MADVISE -e TRANSPARENT_HUGEPAGE_ALWAYS || die
	elif use hugepage-madvise; then
		scripts/config -d TRANSPARENT_HUGEPAGE_ALWAYS -e TRANSPARENT_HUGEPAGE_MADVISE || die
	fi

	for march_flag in "${march_flags[@]}"; do
		if use "${march_flag}"; then
			march=${march_flag#?}
			march=${march^^}
			march=${march//-/_}
			case ${march} in
				GENERIC_V[1-4])
					scripts/config -e GENERIC_CPU -d MZEN4 -d X86_NATIVE_CPU \
						--set-val X86_64_VERSION "${march//GENERIC_V/}" || die
					;;
				ZEN4)
					scripts/config -d GENERIC_CPU -e MZEN4 -d X86_NATIVE_CPU || die
					;;
				NATIVE)
					scripts/config -d GENERIC_CPU -d MZEN4 -e X86_NATIVE_CPU || die
					;;
			esac
			break
		fi
	done

	if [[ -z ${march} ]]; then
		scripts/config -d GENERIC_CPU -d MZEN4 -e X86_NATIVE_CPU || die
	fi

	use autofdo && { scripts/config -e AUTOFDO_CLANG || die; }
	use propeller && { scripts/config -e PROPELLER_CLANG || die; }

	scripts/config --set-str DEFAULT_HOSTNAME gentoo || die

	# Gentoo/OpenRC: restore upstream default console loglevel (CachyOS defaults to 4 for silent systemd boot) #41
	scripts/config --set-val CONSOLE_LOGLEVEL_DEFAULT 7 || die
}

pkg_pretend() {
	CHECKREQS_DISK_BUILD="4G"
	check-reqs_pkg_pretend
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

	elog "For more information about CachyOS kernels, see https://wiki.cachyos.org/features/kernel/."

	if use mnative; then
		ewarn "USE=mnative builds the kernel with -march=native, which optimizes for your"
		ewarn "specific CPU. Binary packages built this way are NOT portable to other machines."
		ewarn "Use USE=mgeneric-v3 or similar for portable builds."
	fi

	optfeature "userspace KSM helper" sys-process/uksmd
	optfeature "NVIDIA open-source module" "x11-drivers/nvidia-drivers[kernel-open]"
	optfeature "NVIDIA module" x11-drivers/nvidia-drivers
	optfeature "Realtek RTL8125 2.5GbE driver" net-misc/r8125
	optfeature "ZFS support" sys-fs/zfs
	optfeature "sched_ext schedulers" sys-kernel/scx-loader

	if use kernel-builtin-zfs; then
		ewarn "WARNING: You are using kernel-builtin-zfs USE flag."
		ewarn "It is STRONGLY RECOMMENDED to use sys-fs/zfs instead of building ZFS into the kernel."
		ewarn "sys-fs/zfs provides better compatibility and easier updates."
		ewarn "Build reference: https://github.com/CachyOS/linux-cachyos/blob/f843b48b52fb52c00f76b7d29f70ba1eb2b4cc06/linux-cachyos-server/PKGBUILD#L573"
		ewarn "See kernel-build.sh in the installed kernel source tree for an example."
	fi
	if use autofdo || use propeller; then
		ewarn "AutoFDO/Propeller are enabled in Kconfig, but they only apply profile-guided"
		ewarn "optimization when you pass a profile at build time:"
		ewarn "  AutoFDO:   CLANG_AUTOFDO_PROFILE=/path/to/profile.afdo"
		ewarn "  Propeller: CLANG_PROPELLER_PROFILE_PREFIX=/path/to/propeller"
		ewarn "Without a profile, CONFIG_PROPELLER_CLANG still adds"
		ewarn "-fbasic-block-address-map / --lto-basic-block-address-map (codegen change, no gain)."
		ewarn "Guide: https://cachyos.org/blog/2411-kernel-autofdo"
		ewarn "Example: https://github.com/xz-dev/kernel-autofdo-container"
	fi
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
