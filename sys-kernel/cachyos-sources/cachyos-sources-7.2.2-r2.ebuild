# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

ETYPE="sources"
EXTRAVERSION="-cachyos"
K_NOSETEXTRAVERSION="1"
# Use the pre-patched CachyOS release tarball.
K_PREPATCHED="1"

# Pin patch and config inputs so Manifest checks cover exact upstream bytes.
CACHYOS_PATCHES_COMMIT="a40b85abdcb9f4ba653e2e1ea89d3d1f0cf563ba"
CACHYOS_CONFIGS_COMMIT="bd8a07da314743eede668d999d37253c1a77c186"
CACHYOS_PR="1"

# Apply Gentoo base and extras fixes on top of the CachyOS release tree.
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="3"
# CachyOS already contains point-release updates and genpatch 2700.
UNIPATCH_EXCLUDE="10 2700"
# The release tarball already carries the exact ${PV} tree.
K_NO_VERSION_CHECK="1"
K_SECURITY_UNSUPPORTED="1"

CJKTTY_PV="7.2"
ZFS_COMMIT="71a9f9578616a90c3c14bb59629fb4d31bfd68d1"
CKV="$(ver_cut 1-3)"
CACHYOS_SERIES="$(ver_cut 1-2)"
CACHYOS_PATCH_URI="https://github.com/CachyOS/kernel-patches/raw/${CACHYOS_PATCHES_COMMIT}/${CACHYOS_SERIES}"
CACHYOS_CONFIG_URI="https://github.com/CachyOS/linux-cachyos/raw/${CACHYOS_CONFIGS_COMMIT}"
CACHYOS_PATCH_PREFIX="cachyos-kernel-patches-${CACHYOS_PATCHES_COMMIT}-${CACHYOS_SERIES}"
CACHYOS_CONFIG_PREFIX="linux-cachyos-${CACHYOS_CONFIGS_COMMIT}"

inherit check-reqs kernel-2 optfeature cjktty

# Initialize kernel-2 version variables before constructing the CachyOS URL.
detect_version
KERNEL_URI="https://github.com/CachyOS/linux/releases/download/cachyos-${CKV}-${CACHYOS_PR}/cachyos-${CKV}-${CACHYOS_PR}.tar.gz"
# CachyOS supplies the complete kernel tree; disable kernel.org incrementals.
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
	${CACHYOS_CONFIG_URI}/linux-cachyos/config
		-> ${CACHYOS_CONFIG_PREFIX}-config
	bore? (
		${CACHYOS_PATCH_URI}/sched/0001-bore-cachy.patch
			-> ${CACHYOS_PATCH_PREFIX}-bore.patch
	)
	bmq? (
		${CACHYOS_PATCH_URI}/sched/0001-prjc-cachy.patch
			-> ${CACHYOS_PATCH_PREFIX}-prjc.patch
	)
	muqss? (
		${CACHYOS_PATCH_URI}/sched/0001-muqss-cachy.patch
			-> ${CACHYOS_PATCH_PREFIX}-muqss.patch
	)
	deckify? (
		${CACHYOS_PATCH_URI}/misc/0001-acpi-call.patch
			-> ${CACHYOS_PATCH_PREFIX}-acpi-call.patch
		${CACHYOS_PATCH_URI}/misc/0001-handheld.patch
			-> ${CACHYOS_PATCH_PREFIX}-handheld.patch
	)
	rt? (
		${CACHYOS_PATCH_URI}/misc/0001-rt-i915.patch
			-> ${CACHYOS_PATCH_PREFIX}-rt-i915.patch
	)
	rt-bore? (
		${CACHYOS_PATCH_URI}/sched/0001-bore-cachy.patch
			-> ${CACHYOS_PATCH_PREFIX}-bore.patch
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
	+bore bmq muqss rt rt-bore eevdf
	server deckify kcfi cjk
	+autofdo +propeller
	+llvm-lto-thin llvm-lto-full llvm-lto-thin-dist llvm-lto-none
	kernel-builtin-zfs
	hz-ticks-100 hz-ticks-250 hz-ticks-300 hz-ticks-500 hz-ticks-600 hz-ticks-750 +hz-ticks-1000
	+per-gov tickrate-periodic tickrate-idle +tickrate-full +preempt-full preempt-lazy
	+o3 os debug +bbr3
	+hugepage-always hugepage-madvise
	mgeneric mgeneric-v1 mgeneric-v2 mgeneric-v3 mgeneric-v4
	+mnative mzen4
"

# OpenZFS does not support Clang CFI: https://github.com/openzfs/zfs/issues/15911
# Scheduler patches carried in kernel-patches but unavailable for 7.2:
# - hardened remains on 7.1.8
# - PRJC-LFBMQ has no 7.2 patch family
# - bare non-Cachy BORE is not used by packaged CachyOS variants
REQUIRED_USE+="
	^^ ( bore bmq muqss rt rt-bore eevdf )
	server? (
		eevdf
		hz-ticks-300 tickrate-full preempt-lazy !per-gov
		llvm-lto-none !autofdo !propeller
		o3 hugepage-always
	)
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

universal_unpack() {
	# Rename the pre-patched CachyOS release directory to kernel-2.eclass's ${S}.
	cd "${WORKDIR}" || die
	unpack "cachyos-${CKV}-${CACHYOS_PR}.tar.gz"
	mv "cachyos-${CKV}-${CACHYOS_PR}" "${S}" || die
	cd "${S}" || die
}

src_unpack() {
	# kernel-2_src_unpack calls the universal_unpack override above.
	kernel-2_src_unpack

	if use kernel-builtin-zfs; then
		# Place pinned ZFS sources inside the installed kernel source tree.
		unpack "zfs-${ZFS_COMMIT}.tar.gz"
		mv "zfs-${ZFS_COMMIT}" zfs || die
		cp "${FILESDIR}/kernel-build.sh" . || die
		chmod +x kernel-build.sh || die
	fi
}

src_prepare() {
	local patches_prefix="${DISTDIR}/${CACHYOS_PATCH_PREFIX}"
	local configs_prefix="${DISTDIR}/${CACHYOS_CONFIG_PREFIX}"
	local cachyos_revision="${PR#r}"
	local cachyos_localversion="-cachyos"
	local march_flag march=""
	local -a march_flags=(
		mgeneric mgeneric-v1 mgeneric-v2 mgeneric-v3 mgeneric-v4 mnative mzen4
	)

	# Add distributed ThinLTO handling omitted by the upstream AutoFDO/Propeller makefiles.
	# https://github.com/Szowisz/CachyOS-kernels/issues/35
	eapply "${FILESDIR}/6.19.0/misc/0002-fix-autofdo-propeller-lto-thin-dist.patch"

	# 7.2.2 changed code that PRJC and MuQSS replace; restore their expected preimage.
	if use bmq || use muqss; then
		eapply "${FILESDIR}/cachyos-sources-7.2.2-revert-empty-cpuset-floor.patch"
	fi

	if use bore || use rt-bore; then
		eapply "${patches_prefix}-bore.patch"
	elif use bmq; then
		eapply "${patches_prefix}-prjc.patch"
	elif use muqss; then
		eapply "${patches_prefix}-muqss.patch"
	fi

	if use rt || use rt-bore; then
		eapply "${patches_prefix}-rt-i915.patch"
	fi

	cp "${configs_prefix}-config" .config || die

	if use deckify; then
		eapply "${patches_prefix}-acpi-call.patch"
		eapply "${patches_prefix}-handheld.patch"
	fi

	if use kcfi || use propeller || ! use llvm-lto-none; then
		eapply "${patches_prefix}-dkms-clang.patch"
	fi

	cjktty_apply_patches
	eapply_user

	# CachyOS ships this generated BPF object; remove it so sources remain rebuildable.
	rm -f tools/testing/selftests/tc-testing/action-ebpf || die

	# Follow upstream localversion naming and append Gentoo's revision when present.
	if [[ ${cachyos_revision} != 0 ]]; then
		cachyos_localversion+="${cachyos_revision}"
	fi
	echo "${cachyos_localversion}" > localversion.20-pkgname || die

	if use server; then
		scripts/config -d CACHY || die
	else
		scripts/config -e CACHY || die
	fi

	if use cjk; then
		# cjktty symbols are mixed-case; scripts/config upper-cases them without --keep-case.
		scripts/config --keep-case -e FONT_CJK_16x16 || die
		# The cjk32 data patch has no effect until its font symbol is explicitly selected.
		use cjk32 && { scripts/config --keep-case -e FONT_CJK_32x32 || die; }
	fi

	if use bore; then
		scripts/config -e SCHED_BORE || die
	elif use bmq; then
		scripts/config -e SCHED_ALT -e SCHED_BMQ || die
	elif use muqss; then
		scripts/config -e SCHED_MUQSS -e MUQSS_IOTIME || die
	elif use rt; then
		scripts/config -e PREEMPT_RT || die
	elif use rt-bore; then
		scripts/config -e SCHED_BORE -e PREEMPT_RT || die
	elif use eevdf; then
		scripts/config -e SCHED_POC_SELECTOR || die
	fi

	if use deckify; then
		scripts/config \
			-d RCU_LAZY_DEFAULT_OFF \
			-e AMD_PRIVATE_COLOR \
			-m SENSORS_STEAMDECK \
			-m MFD_STEAMDECK \
			-m SND_SOC_AW87XXX \
			-m HID_ASUS_ALLY \
			-m HID_LENOVO_GO \
			-m HID_LENOVO_GO_S \
			-m HID_MSI_CLAW \
			-m ZOTAC_ZONE_HID \
			-m LEDS_STEAMDECK \
			-m LEDS_VALVE \
			-e ACPI_CALL \
			-m ZOTAC_ZONE_PLATFORM \
			-m EXTCON_STEAMDECK \
			-m HID_MSI || die
	fi

	if use kcfi; then
		scripts/config -e ARCH_SUPPORTS_CFI_CLANG -e CFI -e CFI_CLANG -e CFI_AUTO_DEFAULT || die
	else
		# OpenZFS does not support Clang CFI: https://github.com/openzfs/zfs/issues/15911
		scripts/config -d CFI -d CFI_CLANG -e CFI_PERMISSIVE || die
	fi

	# Select exactly one LLVM LTO mode from REQUIRED_USE.
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
		die "Invalid HZ_TICKS use flag. Please select a valid option."
	fi

	if use per-gov; then
		scripts/config -d CPU_FREQ_DEFAULT_GOV_SCHEDUTIL -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE || die
	fi

	if use tickrate-periodic; then
		scripts/config -d NO_HZ_IDLE -d NO_HZ_FULL -d NO_HZ -d NO_HZ_COMMON -e HZ_PERIODIC || die
	fi

	if use tickrate-idle; then
		scripts/config -d HZ_PERIODIC -d NO_HZ_FULL -e NO_HZ_IDLE -e NO_HZ -e NO_HZ_COMMON || die
	fi

	if use tickrate-full; then
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
		scripts/config -d CC_OPTIMIZE_FOR_PERFORMANCE \
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
		# Keep vanilla BBR modular while selecting actual BBR3, avoiding duplicate
		# tcp_bbr_check_kfunc_ids BTF sets in vmlinux.
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
	fi

	if use hugepage-madvise; then
		scripts/config -d TRANSPARENT_HUGEPAGE_ALWAYS -e TRANSPARENT_HUGEPAGE_MADVISE || die
	fi

	for march_flag in "${march_flags[@]}"; do
		if use "${march_flag}"; then
			march=${march_flag#?}
			march=${march^^}
			case ${march} in
				GENERIC_V[1-4])
					scripts/config -e GENERIC_CPU -d MZEN4 -d X86_NATIVE_CPU \
						--set-val X86_64_VERSION "${march#GENERIC_V}" || die
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

	scripts/config --set-str DEFAULT_HOSTNAME "gentoo" || die
	# CachyOS lowers this for silent systemd boot; restore Gentoo/OpenRC's default.
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
		ewarn "USE=kernel-builtin-zfs builds ZFS into the kernel."
		ewarn "sys-fs/zfs is the supported path: it tracks kernel updates without a rebuild"
		ewarn "of the kernel itself."
	fi

	if use autofdo || use propeller; then
		ewarn "AutoFDO/Propeller requires profile data to affect optimization."
		ewarn "Without a profile the Kconfig symbols are enabled but nothing is optimized."
	fi
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
