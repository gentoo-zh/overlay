# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

ETYPE="sources"
EXTRAVERSION="-cachyos"
K_NOSETEXTRAVERSION="1"

# Use pre-patched CachyOS tarball from GitHub releases
K_PREPATCHED="1"

# linux-cachyos commit 59d24459dc refreshed the 7.2.0 BMQ config without a
# new source release, so this Gentoo revbump still uses cachyos-7.2.0-1.
CACHYOS_PR="1"

# Genpatches support - apply base and extras patches on top of CachyOS tarball
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="1"

# Exclude kernel version upgrade patches (10xx_linux-*.patch)
# CachyOS tarball already includes the latest point release
# The CachyOS pre-patched tarball already contains genpatch 2700.
UNIPATCH_EXCLUDE="10 2700"

# CachyOS tarball already includes the point release, while we skip Gentoo's
# 10xx point-release genpatches above.
K_NO_VERSION_CHECK="1"
K_SECURITY_UNSUPPORTED="1"

CJKTTY_PV="7.2"
ZFS_COMMIT="92163c55454ad016a4f5be0baca98f95229227df"
CKV="$(ver_cut 1-3)"

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
	kernel-builtin-zfs? (
		https://github.com/cachyos/zfs/archive/${ZFS_COMMIT}.tar.gz
			-> zfs-${ZFS_COMMIT}.tar.gz
	)
"

LICENSE+=" kernel-builtin-zfs? ( BSD-2 CDDL GPL-3 MIT )"
KEYWORDS="~amd64"
IUSE+="
	+bore bmq rt rt-bore eevdf
	deckify kcfi cjk
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
REQUIRED_USE+="
	^^ ( bore bmq rt rt-bore eevdf )
	propeller? ( !llvm-lto-full )
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
	# Exclude genpatch that conflicts with BMQ scheduler
	# 1810_sched_proxy_yield_the_donor_task.patch changes current->sched_class to rq->donor->sched_class
	# which breaks BMQ's patch context for do_sched_yield() and yield_to()
	use bmq && UNIPATCH_EXCLUDE+=" 1810_sched_proxy_yield_the_donor_task.patch"

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
	local files_dir="${FILESDIR}/${PVR}"
	local cachyos_revision="${PR#r}"
	local cachyos_localversion="-cachyos"
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

	if use bore || use rt-bore; then
		eapply "${files_dir}/sched/0001-bore-cachy.patch"
	elif use bmq; then
		eapply "${files_dir}/sched/0001-prjc-cachy.patch"
	fi

	if use rt || use rt-bore; then
		eapply "${files_dir}/misc/0001-rt-i915.patch"
	fi

	if use deckify; then
		# Upstream linux-cachyos-deckify applies the handheld + acpi-call
		# patchsets on top of the pre-patched tarball (see its PKGBUILD source array).
		# This ebuild keeps scheduler choice independent from Deckify.
		eapply "${files_dir}/misc/0001-acpi-call.patch"
		eapply "${files_dir}/misc/0001-handheld.patch"
		cp "${files_dir}/config-deckify" .config || die
	elif use bore; then
		cp "${files_dir}/config-bore" .config || die
	elif use bmq; then
		cp "${files_dir}/config-bmq" .config || die
	elif use eevdf; then
		cp "${files_dir}/config-eevdf" .config || die
	elif use rt || use rt-bore; then
		cp "${files_dir}/config-rt-bore" .config || die
	fi

	if use kcfi || use propeller || use llvm-lto-thin || use llvm-lto-full || use llvm-lto-thin-dist; then
		eapply "${files_dir}/misc/dkms-clang.patch"
	fi

	cjktty_apply_patches
	eapply_user

	# CachyOS ships a prebuilt BPF object in its source tarball.
	rm -f tools/testing/selftests/tc-testing/action-ebpf || die

	# Set kernel version suffix using localversion file (same as upstream PKGBUILD).
	# Keep non-revision ebuilds at -cachyos; append the Gentoo revision number for -rN.
	if [[ ${cachyos_revision} != 0 ]]; then
		cachyos_localversion+="${cachyos_revision}"
	fi
	echo "${cachyos_localversion}" > localversion.20-pkgname || die

	scripts/config -e CACHY || die

	if use bore; then
		scripts/config -e SCHED_BORE || die
	elif use bmq; then
		scripts/config -e SCHED_ALT -e SCHED_BMQ || die
	elif use rt; then
		scripts/config -e PREEMPT_RT || die
	elif use rt-bore; then
		scripts/config -e SCHED_BORE -e PREEMPT_RT || die
	fi

	if use deckify; then
		# Upstream handheld config knobs from linux-cachyos-deckify prepare()
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

	### Enable KCFI
	if use kcfi; then
		scripts/config -e ARCH_SUPPORTS_CFI_CLANG -e CFI -e CFI_CLANG -e CFI_AUTO_DEFAULT || die
	else
		# https://github.com/openzfs/zfs/issues/15911
		scripts/config -d CFI -d CFI_CLANG -e CFI_PERMISSIVE || die
	fi

	### Select LLVM level
	if use llvm-lto-thin; then
		scripts/config -e LTO_CLANG_THIN || die
	elif use llvm-lto-thin-dist; then
		scripts/config -e LTO_CLANG_THIN_DIST || die
	elif use llvm-lto-full; then
		scripts/config -e LTO_CLANG_FULL || die
	elif use llvm-lto-none; then
		scripts/config -e LTO_NONE || die
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

	if use autofdo; then
		scripts/config -e AUTOFDO_CLANG || die
	fi
	if use propeller; then
		scripts/config -e PROPELLER_CLANG || die
	fi

	scripts/config --set-str DEFAULT_HOSTNAME gentoo || die

	# Gentoo/OpenRC: restore upstream default console loglevel (CachyOS defaults to 4 for silent systemd boot) #41
	scripts/config --set-val CONSOLE_LOGLEVEL_DEFAULT 7 || die
}

pkg_pretend() {
	CHECKREQS_DISK_BUILD="4G"
	check-reqs_pkg_pretend
}

pkg_setup() {
	elog
	elog "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	elog "For support, contact https://github.com/gentoo-zh/overlay or the CachyOS developers."
	elog "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	elog "the ebuilds. Thank you."
	elog

	kernel-2_pkg_setup
}

pkg_postinst() {
	local security_unsupported=${K_SECURITY_UNSUPPORTED}
	local K_SECURITY_UNSUPPORTED=

	kernel-2_pkg_postinst

	if [[ -n ${security_unsupported} ]]; then
		elog "${PN} is UNSUPPORTED by Gentoo Security."
		elog "This means that it is likely to be vulnerable to recent security issues."
		elog "Upstream kernel developers recommend always running the latest "
		elog "release of any current long term supported Linux kernel version."
		elog "To see a list of these versions, their most current release and "
		elog "long term support status, please go to https://www.kernel.org ."
		elog "For specific information on why this kernel is unsupported, please read:"
		elog "https://wiki.gentoo.org/wiki/Project:Kernel_Security"
	fi

	elog "For more information about CachyOS kernels, see https://wiki.cachyos.org/features/kernel/."
	optfeature "userspace KSM helper" sys-process/uksmd
	optfeature "NVIDIA open-source module" "x11-drivers/nvidia-drivers[kernel-open]"
	optfeature "NVIDIA module" x11-drivers/nvidia-drivers
	optfeature "Realtek RTL8125 2.5GbE driver" net-misc/r8125
	optfeature "ZFS support" sys-fs/zfs
	optfeature "sched_ext schedulers" sys-kernel/scx-loader

	if use kernel-builtin-zfs; then
		elog "WARNING: You are using kernel-builtin-zfs USE flag."
		elog "It is STRONGLY RECOMMENDED to use sys-fs/zfs instead of building ZFS into the kernel."
		elog "sys-fs/zfs provides better compatibility and easier updates."
		elog "Build reference: https://github.com/CachyOS/linux-cachyos/blob/f843b48b52fb52c00f76b7d29f70ba1eb2b4cc06/linux-cachyos-server/PKGBUILD#L573"
		elog "See kernel-build.sh in the installed kernel source tree for an example."
	fi
	if use autofdo || use propeller; then
		elog "AutoFDO/Propeller are enabled in Kconfig, but they only apply profile-guided"
		elog "optimization when you pass a profile at build time:"
		elog "  AutoFDO:   CLANG_AUTOFDO_PROFILE=/path/to/profile.afdo"
		elog "  Propeller: CLANG_PROPELLER_PROFILE_PREFIX=/path/to/propeller"
		elog "Without a profile, CONFIG_PROPELLER_CLANG still adds"
		elog "-fbasic-block-address-map / --lto-basic-block-address-map (codegen change, no gain)."
		elog "Guide: https://cachyos.org/blog/2411-kernel-autofdo"
		elog "Example: https://github.com/xz-dev/kernel-autofdo-container"
	fi
}

pkg_postrm() {
	kernel-2_pkg_postrm
}

# b3d684160f64763d46da0368d9a1e6f1280e8685
