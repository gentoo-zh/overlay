# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Bumping notes: https://wiki.gentoo.org/wiki/Project:Toolchain/sys-libs/glibc
# Please read & adapt the page as necessary if obsolete.

PYTHON_COMPAT=( python3_{12..14} )
TMPFILES_OPTIONAL=1

EMULTILIB_PKG="true"

# Gentoo patchset (ignored for live ebuilds)
PATCH_VER=4

# liblol additions
GLIBC_PV=2.44
GLIBC_P="glibc-${GLIBC_PV}"
GLIBC_PVR="${GLIBC_PV}"
LOLPREFIX=/opt/lol

LOL_LIBS=(
	math/libm.so.6
	resolv/libresolv.so.2
	malloc/libc_malloc_debug.so.0
	nptl_db/libthread_db.so.1
	locale/libBrokenLocale.so.1
)
LOL_MERGED_LIBS=(
	resolv/libanl.so.1
	dlfcn/libdl.so.2
	rt/librt.so.1
	login/libutil.so.1
	nis/libnsl.so.1
)

# gcc mulitilib bootstrap files version
GCC_BOOTSTRAP_VER=20201208

# systemd integration version
GLIBC_SYSTEMD_VER=20210729

# Minimum kernel version that glibc requires
MIN_KERN_VER="3.2.0"

# Minimum pax-utils version needed (which contains any new syscall changes for
# its seccomp filter!). Please double check this!
MIN_PAX_UTILS_VER="1.3.3"

# Minimum systemd version needed (which contains any new syscall changes for
# its seccomp filter!). Please double check this!
MIN_SYSTEMD_VER="254.9-r1"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/glibc.asc

inherit python-any-r1 prefix preserve-libs toolchain-funcs flag-o-matic gnuconfig \
	multilib systemd multiprocessing tmpfiles eapi9-ver verify-sig

DESCRIPTION="GNU libc C library, for liblol"
HOMEPAGE="https://www.gnu.org/software/libc/ https://liblol.aosc.io"

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
else
	#KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
	KEYWORDS="-* ~loong"
	SRC_URI="mirror://gnu/glibc/${GLIBC_P}.tar.xz"
	SRC_URI+=" verify-sig? ( mirror://gnu/glibc/${GLIBC_P}.tar.xz.sig )"
	SRC_URI+=" https://distfiles.gentoo.org/pub/proj/toolchain/glibc/patches/${GLIBC_P}-patches-${PATCH_VER}.tar.xz"
	SRC_URI+=" https://github.com/AOSC-Dev/liblol/archive/refs/tags/v${PV}.tar.gz -> liblol-${PV}.tar.gz"
fi

SRC_URI+=" multilib-bootstrap? ( https://dev.gentoo.org/~dilfridge/distfiles/gcc-multilib-bootstrap-${GCC_BOOTSTRAP_VER}.tar.xz )"
SRC_URI+=" systemd? ( https://gitweb.gentoo.org/proj/toolchain/glibc-systemd.git/snapshot/glibc-systemd-${GLIBC_SYSTEMD_VER}.tar.gz )"

S="${WORKDIR}/${GLIBC_P}"

LICENSE="LGPL-2.1+ BSD HPND ISC inner-net rc PCRE"
SLOT="2.2"
IUSE="audit caps cet clang compile-locales custom-cflags doc gd hash-sysv-compat headers-only +multiarch multilib multilib-bootstrap nscd perl profile selinux sframe split-usr +ssp stack-realign +static-libs suid systemd systemtap test vanilla"

# Here's how the cross-compile logic breaks down ...
#  CTARGET - machine that will target the binaries
#  CHOST   - machine that will host the binaries
#  CBUILD  - machine that will build the binaries
# If CTARGET != CHOST, it means you want a libc for cross-compiling.
# If CHOST != CBUILD, it means you want to cross-compile the libc.
#  CBUILD = CHOST = CTARGET    - native build/install
#  CBUILD != (CHOST = CTARGET) - cross-compile a native build
#  (CBUILD = CHOST) != CTARGET - libc for cross-compiler
#  CBUILD != CHOST != CTARGET  - cross-compile a libc for a cross-compiler
# For install paths:
#  CHOST = CTARGET  - install into /
#  CHOST != CTARGET - install into /usr/CTARGET/
#
export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY} == cross-* ]] ; then
		export CTARGET=${CATEGORY#cross-}
	fi
fi

# Note [Disable automatic stripping]
# Disabling automatic stripping for a few reasons:
# - portage's attempt to strip breaks non-native binaries at least on
#   arm: bug #697428
# - portage's attempt to strip libpthread.so.0 breaks gdb thread
#   enumeration: bug #697910. This is quite subtle:
#   * gdb uses glibc's libthread_db-1.0.so to enumerate threads.
#   * libthread_db-1.0.so needs access to libpthread.so.0 local symbols
#     via 'ps_pglobal_lookup' symbol defined in gdb.
#   * 'ps_pglobal_lookup' uses '.symtab' section table to resolve all
#     known symbols in 'libpthread.so.0'. Specifically 'nptl_version'
#     (unexported) is used to sanity check compatibility before enabling
#     debugging.
#     Also see https://sourceware.org/gdb/wiki/FAQ#GDB_does_not_see_any_threads_besides_the_one_in_which_crash_occurred.3B_or_SIGTRAP_kills_my_program_when_I_set_a_breakpoint
#   * normal 'strip' command trims '.symtab'
#   Thus our main goal here is to prevent 'libpthread.so.0' from
#   losing it's '.symtab' entries.
# - similarly, valgrind requires knowledge about symbols in ld.so:
#	bug #920753
# As Gentoo's strip does not allow us to pass less aggressive stripping
# options and does not check the machine target we strip selectively.

# We need a new-enough binutils/gcc to match upstream baseline.
# Also we need to make sure our binutils/gcc supports TLS,
# and that gcc already contains the hardened patches.
# Lastly, let's avoid some openssh nastiness, bug 708224, as
# convenience to our users.

IDEPEND="
	!compile-locales? ( sys-apps/locale-gen )
"
BDEPEND="
	${PYTHON_DEPS}
	>=app-misc/pax-utils-${MIN_PAX_UTILS_VER}
	>=dev-util/patchelf-liblol-0.1.9
	sys-devel/bison
	compile-locales? ( sys-apps/locale-gen )
	doc? (
		dev-lang/perl
		sys-apps/texinfo
	)
	sframe? ( >=sys-devel/binutils-2.45 )
	test? (
		dev-lang/perl
		>=net-dns/libidn2-2.3.0
		sys-apps/gawk[mpfr]
	)
	verify-sig? ( sec-keys/openpgp-keys-glibc )
"
COMMON_DEPEND="
	gd? ( media-libs/gd:2= )
	nscd? ( selinux? (
		audit? ( sys-process/audit )
		caps? ( sys-libs/libcap )
	) )
	suid? ( caps? ( sys-libs/libcap ) )
	selinux? ( sys-libs/libselinux )
	systemtap? ( dev-debug/systemtap )
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
	!<app-emulation/liblol-0.1.0
	!<app-misc/pax-utils-${MIN_PAX_UTILS_VER}
	!<sys-apps/systemd-${MIN_SYSTEMD_VER}
	perl? ( dev-lang/perl )
"

RESTRICT="!test? ( test )"

if [[ ${CATEGORY} == cross-* ]] ; then
	BDEPEND+=" !headers-only? (
		>=${CATEGORY}/binutils-2.27
		>=${CATEGORY}/gcc-6.2
	)"

	case ${CATEGORY} in
		*-linux*)
			DEPEND+=" ${CATEGORY}/linux-headers"
			;;
		*-gnu)
			DEPEND+=" ${CATEGORY}/gnumach[-headers-only]"
			;;
	esac
else
	BDEPEND+="
		>=sys-devel/binutils-2.27
		clang? ( || ( ( >=sys-devel/gcc-6.2 )
			( >=sys-devel/gcc-6.2 >=llvm-core/clang-18 )
			( >=llvm-core/clang-18 >=llvm-runtimes/libgcc-18 ) ) )
		!clang? ( >=sys-devel/gcc-6.2 )
	"
	DEPEND+=" virtual/os-headers "
	RDEPEND+="
		>=net-dns/libidn2-2.3.0
		vanilla? ( !sys-libs/timezone-data )
	"
	PDEPEND+=" !vanilla? ( sys-libs/timezone-data )"

fi

# Ignore tests whitelisted below
GENTOO_GLIBC_XFAIL_TESTS="${GENTOO_GLIBC_XFAIL_TESTS:-yes}"

# The following tests fail due to the Gentoo build system and are thus
# executed but ignored:
XFAIL_TEST_LIST=(
	# buggy test, assumes /dev/ and /dev/null on a single filesystem
	# 'mount --bind /dev/null /chroot/dev/null' breaks it.
	# https://sourceware.org/PR25909
	tst-support_descriptors

	# The following tests fail only inside portage
	# https://bugs.gentoo.org/831267
	tst-system
	tst-strerror
	tst-strsignal

	# Fails with certain PORTAGE_NICENESS/PORTAGE_SCHEDULING_POLICY
	tst-sched1
	tst-sched_setattr
	tst-sched_setattr-thread

	# Fails regularly, unreliable
	tst-valgrind-smoke

	# https://sourceware.org/bugzilla/show_bug.cgi?id=31877 (bug #927973)
	tst-shstk-legacy-1g

	# https://sourceware.org/bugzilla/show_bug.cgi?id=33239
	test-double-compoundn
	test-float-compoundn
	test-float32-compoundn
	test-float32x-compoundn
	test-float64-compoundn

	# Fails only in portage. Needs investigation.
	tst-setvbuf2

	# https://sourceware.org/PR34433
	tst-dl-llp-stack
)

XFAIL_NSPAWN_TEST_LIST=(
	# These tests need to be adapted to handle EPERM/ENOSYS(?) properly
	# upstream, as systemd-nspawn's default seccomp whitelist is too strict.
	# https://sourceware.org/PR30603
	test-errno-linux
	tst-aarch64-pkey
	tst-bz21269
	tst-mlock2
	tst-mseal-pkey
	tst-ntp_gettime
	tst-ntp_gettime-time64
	tst-ntp_gettimex
	tst-ntp_gettimex-time64
	tst-pkey
	tst-process_mrelease
	tst-adjtime
	tst-adjtime-time64
	tst-clock2
	tst-clock2-time64

	# These fail if --suppress-sync and/or low priority is set
	tst-sync_file_range
	test-errno
)

#
# Small helper functions
#

dump_build_environment() {
	einfo ==== glibc build environment ========================================================
	local v
	for v in ABI CBUILD CHOST CTARGET CBUILD_OPT CTARGET_OPT CC CXX CPP LD \
		{AS,C,CPP,CXX,LD}FLAGS MAKEINFO NM AR AS STRIP RANLIB OBJCOPY \
		STRINGS OBJDUMP READELF; do
		einfo " $(printf '%15s' ${v}:)   ${!v}"
	done
	einfo =====================================================================================
}

is_crosscompile() {
	[[ ${CHOST} != ${CTARGET} ]]
}

is_linux() {
	[[ ${CTARGET} == *-linux-* ]]
}

is_hurd() {
	# Let's hope this holds for a long time
	[[ ${CTARGET} != *-linux-* ]]
}

just_headers() {
	is_crosscompile && use headers-only
}

alt_prefix() {
	is_crosscompile && echo /usr/${CTARGET}
}

# This prefix is applicable to CHOST when building against this
# glibc. It is baked into the library at configure time.
host_eprefix() {
	is_crosscompile || echo "${EPREFIX}"
}

eprefix_lol() {
	echo "${EPREFIX}${LOLPREFIX}"
}

# This prefix is applicable to CBUILD when building against this
# glibc. It determines the destination path at install time.
build_eprefix() {
	is_crosscompile && echo "${EPREFIX}"
}

alt_headers() {
	echo $(alt_prefix)/usr/include
}
alt_libdir() {
	echo $(alt_prefix)${LOLPREFIX}/$(get_libdir)
}
alt_usrlibdir() {
	echo $(alt_prefix)${LOLPREFIX}/usr/$(get_libdir)
}

builddir() {
	echo "${WORKDIR}/build-${ABI}-${CTARGET}-$1"
}

do_compile_test() {
	local ret save_cflags=${CFLAGS}
	CFLAGS+=" $1"
	shift

	pushd "${T}" >/dev/null

	rm -f glibc-test*
	printf '%b' "$*" > glibc-test.c

	# We assume CC is already set up.
	nonfatal emake glibc-test
	ret=$?

	popd >/dev/null

	CFLAGS=${save_cflags}
	return ${ret}
}

do_run_test() {
	local ret

	if [[ ${MERGE_TYPE} == "binary" ]] ; then
		# ignore build failures when installing a binary package #324685
		CC="${glibc__ORIG_CC}" CXX="${glibc__ORIG_CXX}" CPP="${glibc__ORIG_CPP}" \
			CFLAGS="-O2" LDFLAGS="" do_compile_test "" "$@" 2>/dev/null || return 0
	else
		ebegin "Performing simple compile test for ABI=${ABI}"
		if ! do_compile_test "" "$@" ; then
			ewarn "Simple build failed ... assuming this is desired #324685"
			eend 1
			return 0
		else
			eend 0
		fi
	fi

	pushd "${T}" >/dev/null

	./glibc-test
	ret=$?
	rm -f glibc-test*

	popd >/dev/null

	return ${ret}
}

setup_target_flags() {
	# This largely mucks with compiler flags.  None of which should matter
	# when building up just the headers.
	just_headers && return 0

	case $(tc-arch) in
		alpha)
			# glibc selects its hand-written assembly mem*/str* routines by the
			# host triplet's machine prefix (sysdeps/alpha/preconfigure does
			# machine=alpha/$machine), NOT by the -mcpu codegen flag.  With the
			# bare alpha-*-* CHOST only the generic C is built.  Map -mcpu to the
			# most specific sysdeps/alpha/alphaev* dir that exists (Implies chain
			# alphaev67 -> alphaev6 -> alphaev5) so the tuned asm is selected.
			local cpu
			case $(get-flag mcpu) in
			21264a|ev67)           cpu="alphaev67" ;;
			21264|ev6)             cpu="alphaev6" ;;
			21164*|ev5|ev56|pca56) cpu="alphaev5" ;;
			esac
			[[ -n ${cpu} ]] && CTARGET_OPT="${cpu}-${CTARGET#*-}"
		;;
		x86)
			# -march needed for #185404 #199334
			# TODO: When creating the first glibc cross-compile, this test will
			# always fail as it does a full link which in turn requires glibc.
			# Probably also applies when changing multilib profile settings (e.g.
			# enabling x86 when the profile was amd64-only previously).
			# We could change main to _start and pass -nostdlib here so that we
			# only test the gcc code compilation.  Or we could do a compile and
			# then look for the symbol via scanelf.
			if ! do_compile_test "" 'void f(int i, void *p) {if (__sync_fetch_and_add(&i, 1)) f(i, p);}\nint main(){return 0;}\n'; then
				local t=${CTARGET_OPT:-${CTARGET}}
				t=${t%%-*}
				filter-flags '-march=*'
				export CFLAGS="-march=${t} ${CFLAGS}"
				einfo "Auto adding -march=${t} to CFLAGS #185404"
			fi
			# For compatibility with older binaries at slight performance cost.
			use stack-realign && export CFLAGS+=" -mstackrealign"
		;;
		amd64)
			# -march needed for #185404 #199334
			# TODO: See cross-compile issues listed above for x86.
			if [[ ${ABI} == x86 ]]; then
				if ! do_compile_test "${CFLAGS_x86}" 'void f(int i, void *p) {if (__sync_fetch_and_add(&i, 1)) f(i, p);}\nint main(){return 0;}\n'; then
					local t=${CTARGET_OPT:-${CTARGET}}
					t=${t%%-*}
					# Normally the target is x86_64-xxx, so turn that into the -march that
					# gcc actually accepts. #528708
					[[ ${t} == "x86_64" ]] && t="x86-64"
					filter-flags '-march=*'
					# ugly, ugly, ugly.  ugly.
					CFLAGS_x86=$(
						CFLAGS=${CFLAGS_x86}
						filter-flags '-march=*'
						is-flagq '-mfpmath=sse' && append-cflags -msse
						echo "${CFLAGS}"
					)
					export CFLAGS_x86="${CFLAGS_x86} -march=${t}"
					einfo "Auto adding -march=${t} to CFLAGS_x86 #185404 (ABI=${ABI})"
				fi
				# For compatibility with older binaries at slight performance cost.
				use stack-realign && export CFLAGS_x86+=" -mstackrealign"
			fi
		;;
		mips)
			# The mips abi cannot support the GNU style hashes. #233233
			filter-ldflags -Wl,--hash-style=gnu -Wl,--hash-style=both
		;;
		ppc|ppc64)
			# Many arch-specific implementations do not work on ppc with
			# cache-block not equal to 128 bytes. This breaks memset:
			#   https://sourceware.org/PR26522
			#   https://bugs.gentoo.org/737996
			# Use default -mcpu=. For ppc it means non-multiarch setup.
			filter-flags '-mcpu=*'
		;;
		sparc)
			# Both sparc and sparc64 can use -fcall-used-g6.  -g7 is bad, though.
			filter-flags "-fcall-used-g7"
			append-flags "-fcall-used-g6"

			local cpu
			case ${CTARGET} in
			sparc64-*)
				cpu="sparc64"
				case $(get-flag mcpu) in
				v9)
					# We need to force at least v9a because the base build doesn't
					# work with just v9.
					# https://sourceware.org/bugzilla/show_bug.cgi?id=19477
					append-flags "-Wa,-xarch=v9a"
					;;
				esac
				;;
			sparc-*)
				case $(get-flag mcpu) in
				v8|supersparc|hypersparc|leon|leon3)
					cpu="sparcv8"
					;;
				*)
					cpu="sparcv9"
					;;
				esac
			;;
			esac
			[[ -n ${cpu} ]] && CTARGET_OPT="${cpu}-${CTARGET#*-}"
		;;
	esac
}

setup_flags() {
	# Make sure host make.conf doesn't pollute us
	if is_crosscompile || tc-is-cross-compiler ; then
		CHOST=${CTARGET} strip-unsupported-flags
	fi

	# Store our CFLAGS because it's changed depending on which CTARGET
	# we are building when pulling glibc on a multilib profile
	CFLAGS_BASE=${CFLAGS_BASE-${CFLAGS}}
	CFLAGS=${CFLAGS_BASE}
	CXXFLAGS_BASE=${CXXFLAGS_BASE-${CXXFLAGS}}
	CXXFLAGS=${CXXFLAGS_BASE}
	ASFLAGS_BASE=${ASFLAGS_BASE-${ASFLAGS}}
	ASFLAGS=${ASFLAGS_BASE}

	# Allow users to explicitly avoid flag sanitization via
	# USE=custom-cflags.
	if ! use custom-cflags; then
		# Over-zealous CFLAGS can often cause problems.  What may work for one
		# person may not work for another.  To avoid a large influx of bugs
		# relating to failed builds, we strip most CFLAGS out to ensure as few
		# problems as possible.
		strip-flags

		# Allow -O2 and -O3, but nothing else for now.
		# TODO: Test -Os, -Oz.
		if ! is-flagq '-O@(2|3)' ; then
			# Lock glibc at -O2. We want to be conservative here.
			filter-flags '-O?'
			append-flags -O2
		fi
	fi

	strip-unsupported-flags
	filter-lto
	filter-flags -m32 -m64 '-mabi=*'

	# glibc aborts if rpath is set by LDFLAGS
	filter-ldflags '-Wl,-rpath=*'

	# ld can't use -r & --relax at the same time, bug #788901
	# https://sourceware.org/PR27837
	filter-ldflags '-Wl,--relax'

	# Flag added for cross-prefix, but causes ldconfig to segfault. Not needed
	# anyway because glibc already handles this by itself.
	filter-ldflags '-Wl,--dynamic-linker=*'

	# Fails to link (bug #940709) in some cases but even if it manages to,
	# subtle runtime breakage will occur because the linker scripts need
	# adaptation. Mentioned in PR21557#c0.
	filter-ldflags '-Wl,--gc-sections'

	# some weird software relies on sysv hashes in glibc, bug 863863, bug 864100
	# we have to do that here already so mips can filter it out again :P
	if use hash-sysv-compat ; then
		append-ldflags '-Wl,--hash-style=both'
	fi

	# clang warns about linker flags unused during compilation, but we don't
	# want that to turn into errors!
	# Let's turn the warning off entirely since it spams.
	append-flags -Wno-unused-command-line-argument

	# #492892
	filter-flags -frecord-gcc-switches

	# #898098
	filter-flags -fno-builtin

	# #798774
	filter-flags -fno-semantic-interposition

	# #829583
	filter-lfs-flags

	case ${CTARGET} in
		*-linux*)
			;;
		*-gnu)
			# -g3 confuses MIG which relies on preprocessed input
			replace-flags -ggdb[3-9] -ggdb2
			replace-flags -g3 -g
			;;
	esac

	unset CBUILD_OPT CTARGET_OPT
	if use multilib ; then
		CTARGET_OPT=$(get_abi_CTARGET)
		[[ -z ${CTARGET_OPT} ]] && CTARGET_OPT=$(get_abi_CHOST)
	fi

	setup_target_flags

	if [[ -n ${CTARGET_OPT} && ${CBUILD} == ${CHOST} ]] && ! is_crosscompile; then
		CBUILD_OPT=${CTARGET_OPT}
	fi

	# glibc's headers disallow -O0 and fail at build time:
	#  include/libc-symbols.h:75:3: #error "glibc cannot be compiled without optimization"
	# https://sourceware.org/glibc/wiki/FAQ#Why_do_I_get:.60.23error_.22glibc_cannot_be_compiled_without_optimization.22.27.2C_when_trying_to_compile_GNU_libc_with_GNU_CC.3F
	replace-flags -O0 -O1

	# bug #982652 (PR34672)
	is_hurd && replace-flags -Os -O2

	# Similar issues as with SSP. Can't inject yourself that early.
	filter-flags '-fsanitize=*'

	# See end of bug #830454; we handle this via USE=cet
	filter-flags '-fcf-protection=*'

	# When bootstrapping, we may have a situation where
	# CET-enabled gcc from seed is used to build CET-disabled
	# glibc. As such, gcc implicitly enables CET if no
	# -fcf-protection flag is passed. For a typical package it
	# should not be a problem, but for glibc it matters as it is
	# dealing with CET in ld.so. So if CET is supposed to be
	# disabled for glibc, be explicit about it.
	if ! use cet; then
		case ${ABI}-${CTARGET} in
			amd64-x86_64-*|x32-x86_64-*-*-gnux32)
				append-flags '-fcf-protection=none'
				;;
			arm64-aarch64*)
				append-flags '-mbranch-protection=none'
				;;
		esac
	fi
}

use_multiarch() {
	# Allow user to disable runtime arch detection in multilib.
	use multiarch || return 1
	# Make sure binutils is new enough to support indirect functions,
	# #336792. This funky sed supports gold and bfd linkers.
	local bver nver
	bver=$($(tc-getLD ${CTARGET}) -v | sed -n -r '1{s:[^0-9]*::;s:^([0-9.]*).*:\1:;p}')
	case $(tc-arch ${CTARGET}) in
	amd64|x86) nver="2.20" ;;
	arm)       nver="2.22" ;;
	hppa)      nver="2.23" ;;
	ppc|ppc64) nver="2.20" ;;
	# ifunc support was added in 2.23, but glibc also needs
	# machinemode which is in 2.24.
	s390)      nver="2.24" ;;
	sparc)     nver="2.21" ;;
	*)         return 1 ;;
	esac
	ver_test ${bver} -ge ${nver}
}

# Setup toolchain variables that had historically been defined in the
# profiles for these archs.
setup_env() {
	# silly users
	unset LD_RUN_PATH
	unset LD_ASSUME_KERNEL

	if is_crosscompile || tc-is-cross-compiler ; then
		multilib_env ${CTARGET_OPT:-${CTARGET}}

		if ! use multilib ; then
			MULTILIB_ABIS=${DEFAULT_ABI}
		else
			MULTILIB_ABIS=${MULTILIB_ABIS:-${DEFAULT_ABI}}
		fi

		# If the user has CFLAGS_<CTARGET> in their make.conf, use that,
		# and fall back on CFLAGS.
		local VAR=CFLAGS_${CTARGET//[-.]/_}
		CFLAGS=${!VAR-${CFLAGS}}
		einfo " $(printf '%15s' 'Manual CFLAGS:')   ${CFLAGS}"
	fi

	setup_flags

	export ABI=${ABI:-${DEFAULT_ABI:-default}}

	if just_headers ; then
		# Avoid mixing host's CC and target's CFLAGS_${ABI}:
		# At this bootstrap stage we have only binutils for
		# target but not compiler yet.
		einfo "Skip CC ABI injection. We can't use (cross-)compiler yet."
		return 0
	fi

	# glibc does not work with non-bfd (for various reasons):
	# * gold (bug #269274)
	# * mold (bug #860900)
	tc-ld-force-bfd

	if use doc ; then
		export MAKEINFO=makeinfo
	else
		export MAKEINFO=/dev/null
	fi

	# Reset CC and CXX to the value at start of emerge
	export CC=${glibc__ORIG_CC:-${CC:-$(tc-getCC ${CTARGET})}}
	export CXX=${glibc__ORIG_CXX:-${CXX:-$(tc-getCXX ${CTARGET})}}
	export CPP=${glibc__ORIG_CPP:-${CPP:-$(tc-getCPP ${CTARGET})}}

	# and make sure glibc__ORIG_CC and glibc__ORIG_CXX is defined now.
	export glibc__ORIG_CC=${CC}
	export glibc__ORIG_CXX=${CXX}
	export glibc__ORIG_CPP=${CPP}

	if tc-is-clang && ! ( use clang || use custom-cflags ) && ! is_crosscompile ; then
		export glibc__force_gcc=yes
		# once this is toggled on, it needs to stay on, since with CPP manipulated
		# tc-is-clang does not work correctly anymore...
	fi

	if [[ ${glibc__force_gcc} == "yes" ]] ; then
		# If we are running in an otherwise clang/llvm environment, we need to
		# recover the proper gcc and binutils settings here, at least until glibc
		# is finally building with clang. So let's override everything that is
		# set in the clang profiles.
		# Want to shoot yourself into the foot? Set USE="clang" or USE="custom-cflags".
		# Also, if you are crosscompiling, let's assume you know what you are doing.
		# Hopefully.
		# Last, we need the settings of the *build* environment, not of the
		# target environment...

		local current_binutils_path=$(env CHOST="${CBUILD}" ROOT="${BROOT}" binutils-config -B "${CTARGET}")
		local current_gcc_path=$(env ROOT="${BROOT}" gcc-config -B)
		einfo "Overriding clang configuration, since it won't work here"

		export CC="${current_gcc_path}/${CTARGET}-gcc"
		export CPP="${current_gcc_path}/${CTARGET}-cpp"
		export CXX="${current_gcc_path}/${CTARGET}-g++"
		export LD="${current_binutils_path}/ld.bfd"
		export AR="${current_binutils_path}/ar"
		export AS="${current_binutils_path}/as"
		export NM="${current_binutils_path}/nm"
		export STRIP="${current_binutils_path}/strip"
		export RANLIB="${current_binutils_path}/ranlib"
		export OBJCOPY="${current_binutils_path}/objcopy"
		export STRINGS="${current_binutils_path}/strings"
		export OBJDUMP="${current_binutils_path}/objdump"
		export READELF="${current_binutils_path}/readelf"
		export ADDR2LINE="${current_binutils_path}/addr2line"

		# do we need to also do flags munging here? yes! at least...
		filter-flags '-fuse-ld=*'
		filter-flags '-D_FORTIFY_SOURCE=*'

	else
		# this is the "normal" case

		# Always use tuple-prefixed toolchain. For non-native ABI glibc's configure
		# can't detect them automatically due to ${CHOST} mismatch and fallbacks
		# to unprefixed tools. Similar to multilib.eclass:multilib_toolchain_setup().
		export CC="$(tc-getCC ${CTARGET})"
		export CXX="$(tc-getCXX ${CTARGET})"
		export CPP="$(tc-getCPP ${CTARGET})"
		export NM="$(tc-getNM ${CTARGET})"
		export READELF="$(tc-getREADELF ${CTARGET})"

	fi

	# We need to move CFLAGS with abi information into CC etc per glibc upstream
	# requirement. Keep around the original clean value to avoid appending
	# multiple ABIs on top of each other.
	export glibc__GLIBC_CC=${CC}
	export glibc__GLIBC_CXX=${CXX}
	export glibc__GLIBC_CPP=${CPP}

	export glibc__abi_CFLAGS="$(get_abi_CFLAGS)"

	# CFLAGS can contain ABI-specific flags like -mfpu=neon, see bug #657760
	# To build .S (assembly) files with the same ABI-specific flags
	# upstream currently recommends adding CFLAGS to CC/CXX:
	#    https://sourceware.org/PR23273
	# Note: Passing CFLAGS via CPPFLAGS overrides glibc's arch-specific CFLAGS
	# and breaks multiarch support. See 659030#c3 for an example.
	# The glibc configure script doesn't properly use LDFLAGS all the time.
	export CC="${glibc__GLIBC_CC} ${glibc__abi_CFLAGS} ${CFLAGS} ${LDFLAGS}"

	# Some of the tests are written in C++, so we need to force our multlib abis in, bug 623548
	export CXX="${glibc__GLIBC_CXX} ${glibc__abi_CFLAGS} ${CFLAGS}"

	export CPP="${glibc__GLIBC_CPP} ${glibc__abi_CFLAGS} ${CFLAGS}"

	if is_crosscompile; then
		# Assume worst-case bootstrap: glibc is built for the first time
		# with ${CTARGET}-g++ not available yet. We avoid
		# building auxiliary programs that require C++: bug #683074
		# It should not affect final result.
		export libc_cv_cxx_link_ok=no
		# The line above has the same effect. We set CXX explicitly
		# to make build logs less confusing.
		export CXX=
	fi
}

foreach_abi() {
	setup_env

	local ret=0
	local abilist=""
	if use multilib ; then
		abilist=$(get_install_abis)
	else
		abilist=${DEFAULT_ABI}
	fi
	local -x ABI
	for ABI in ${abilist:-default} ; do
		setup_env
		einfo "Running $1 for ABI ${ABI}"
		$1
		: $(( ret |= $? ))
	done
	return ${ret}
}

glibc_banner() {
	local b="Gentoo ${GLIBC_PVR}"
	[[ -n ${PATCH_VER} ]] && ! use vanilla && b+=" (patchset ${PATCH_VER})"
	echo "${b}, LibLoL ${PVR}"
}

# The following Kernel version handling functions are mostly copied from portage
# source. It's better not to use linux-info.eclass here since a) it adds too
# much magic, see bug 326693 for some of the arguments, and b) some of the
# functions are just not provided.

g_get_running_KV() {
	uname -r
	return $?
}

g_KV_major() {
	[[ -z $1 ]] && return 1
	local KV=$@
	echo "${KV%%.*}"
}

g_KV_minor() {
	[[ -z $1 ]] && return 1
	local KV=$@
	KV=${KV#*.}
	echo "${KV%%.*}"
}

g_KV_micro() {
	[[ -z $1 ]] && return 1
	local KV=$@
	KV=${KV#*.*.}
	echo "${KV%%[^[:digit:]]*}"
}

g_KV_to_int() {
	[[ -z $1 ]] && return 1
	local KV_MAJOR=$(g_KV_major "$1")
	local KV_MINOR=$(g_KV_minor "$1")
	local KV_MICRO=$(g_KV_micro "$1")
	local KV_int=$(( KV_MAJOR * 65536 + KV_MINOR * 256 + KV_MICRO ))

	# We make version 2.2.0 the minimum version we will handle as
	# a sanity check ... if its less, we fail ...
	if [[ ${KV_int} -ge 131584 ]] ; then
		echo "${KV_int}"
		return 0
	fi
	return 1
}

g_int_to_KV() {
	local version=$1 major minor micro
	major=$((version / 65536))
	minor=$(((version % 65536) / 256))
	micro=$((version % 256))
	echo ${major}.${minor}.${micro}
}

get_kheader_version() {
	printf '#include <linux/version.h>\nLINUX_VERSION_CODE\n' | \
	$(tc-getCPP ${CTARGET}) -I "${ESYSROOT}$(alt_headers)" - | \
	tail -n 1
}

# We collect all sanity checks here. Consistency is not guranteed between
# pkg_ and src_ phases, so we call this function both in pkg_pretend and in
# src_unpack.
sanity_prechecks() {
	# Prevent native builds from downgrading
	if [[ ${MERGE_TYPE} != "buildonly" ]] && \
	   [[ -z ${ROOT} ]] && \
	   [[ ${CBUILD} == ${CHOST} ]] && \
	   [[ ${CHOST} == ${CTARGET} ]] ; then

		# The high rev # is to allow people to downgrade between -r#
		# versions. We want to block 2.20->2.19, but 2.20-r3->2.20-r2
		# should be fine. Hopefully we never actually use a r# this
		# high.
		if has_version ">${CATEGORY}/${P}-r10000" ; then
			eerror "Sanity check to keep you from breaking your system:"
			eerror " Downgrading glibc is not supported and a sure way to destruction."
			[[ ${I_ALLOW_TO_BREAK_MY_SYSTEM} = yes ]] || die "Aborting to save your system."
		fi

		if is_linux && ! do_run_test '#include <unistd.h>\n#include <sys/syscall.h>\nint main(){return syscall(1000)!=-1;}\n' ; then
			eerror "Your old kernel is broken. You need to update it to a newer"
			eerror "version as syscall(<bignum>) will break. See bug 279260."
			[[ ${I_ALLOW_TO_BREAK_MY_SYSTEM} = yes ]] || die "Old and broken kernel."
		fi
	fi

	if [[ ${CTARGET} == i386-* ]] ; then
		eerror "i386 CHOSTs are no longer supported."
		eerror "Chances are you don't actually want/need i386."
		eerror "Please read https://www.gentoo.org/doc/en/change-chost.xml"
		die "Please fix your CHOST"
	fi

	if [[ -e /proc/xen ]] && [[ $(tc-arch) == "x86" ]] && ! is-flag -mno-tls-direct-seg-refs ; then
		ewarn "You are using Xen but don't have -mno-tls-direct-seg-refs in your CFLAGS."
		ewarn "This will result in a 50% performance penalty when running with a 32bit"
		ewarn "hypervisor, which is probably not what you want."
	fi

	# ABI-specific checks follow here. Hey, we have a lot more specific conditions that
	# we test for...
	if ! is_crosscompile && ! tc-is-cross-compiler ; then
		if use amd64 && use multilib && [[ ${MERGE_TYPE} != "binary" ]] ; then
			ebegin "Checking if the system can execute 32-bit binaries"
			echo 'int main(){return 0;}' > "${T}/check-ia32-emulation.c"
			local STAT
			if ${CC-${CHOST}-gcc} ${CFLAGS_x86} "${T}/check-ia32-emulation.c" -o "${T}/check-ia32-emulation.elf32"; then
				"${T}/check-ia32-emulation.elf32"
				STAT=$?
			else
				# Don't fail here to allow single->multi ABI switch
				# or recover from breakage like bug #646424
				ewarn "Failed to compile the ABI test. Broken host glibc?"
				STAT=0
			fi
			rm -f "${T}/check-ia32-emulation.elf32"
			eend $STAT
			if [[ $STAT -ne 0 ]]; then
				eerror "Ensure that CONFIG_IA32_EMULATION is enabled in the kernel."
				eerror "Seek support otherwise."
				die "Unable to execute 32-bit binaries"
			fi
		fi

	fi

	# When we actually have to compile something...
	if ! just_headers && [[ ${MERGE_TYPE} != "binary" ]] ; then
		if [[ -d "${ESYSROOT}"/usr/lib/include ]] ; then
			# bug #833620, bug #643302
			eerror "Found ${ESYSROOT}/usr/lib/include directory!"
			eerror "This is known to break glibc's build."
			eerror "Please backup its contents then remove the directory."
			die "Found directory (${ESYSROOT}/usr/lib/include) which will break build (bug #833620)!"
		fi

		if is_linux ; then
			local run_kv build_kv want_kv

			run_kv=$(g_get_running_KV)
			build_kv=$(g_int_to_KV $(get_kheader_version))
			want_kv=${MIN_KERN_VER}

			if ! is_crosscompile && ! tc-is-cross-compiler ; then
				# Building fails on an non-supporting kernel
				ebegin "Checking running kernel version (${run_kv} >= ${want_kv})"
				if ! [[ $(g_KV_to_int ${run_kv}) -ge $(g_KV_to_int ${want_kv}) ]] ; then
					eend 1
					echo
					eerror "You need a kernel of at least ${want_kv}!"
					die "Kernel version too low!"
				fi
				eend 0
			fi

			# Do not run this check for pkg_pretend, just pkg_setup and friends (if we ever get used there).
			# It's plausible (seen it in the wild) that Portage will (correctly) schedule a linux-headers
			# upgrade before glibc, but because pkg_pretend gets run before any packages are merged at all (not
			# just glibc), the whole emerge gets aborted without a good reason. We probably don't
			# need to run this check at all given we have a dependency on the right headers,
			# but let's leave it as-is for now.
			if [[ ${EBUILD_PHASE_FUNC} != pkg_pretend ]] ; then
				ebegin "Checking linux-headers version (${build_kv} >= ${want_kv})"
				if ! [[ $(g_KV_to_int ${build_kv}) -ge $(g_KV_to_int ${want_kv}) ]] ; then
					eend 1
					echo
					eerror "You need linux-headers of at least ${want_kv}!"
					die "linux-headers version too low!"
				fi
				eend 0
			fi
		fi
	fi
}

upgrade_warning() {
	# unneeded for liblol
	return
}

#
# the phases
#

# pkg_pretend

pkg_pretend() {
	upgrade_warning
}

# pkg_setup

pkg_setup() {
	# see bug 682570
	[[ -z ${BOOTSTRAP_RAP} ]] && python-any-r1_pkg_setup
}

# src_unpack

src_unpack() {
	setup_env

	einfo "Checking general environment sanity."
	sanity_prechecks

	use multilib-bootstrap && unpack gcc-multilib-bootstrap-${GCC_BOOTSTRAP_VER}.tar.xz

	if [[ ${PV} == *9999 ]] ; then
		EGIT_REPO_URI="
			https://anongit.gentoo.org/git/proj/toolchain/glibc-patches.git
			https://github.com/gentoo/glibc-patches.git
		"
		EGIT_CHECKOUT_DIR=${WORKDIR}/patches-git
		git-r3_src_unpack
		mv patches-git/9999 patches || die
		EGIT_REPO_URI="
			https://sourceware.org/git/glibc.git
			https://git.sr.ht/~sourceware/glibc
			https://gitlab.com/x86-glibc/glibc.git
		"
		EGIT_CHECKOUT_DIR=${S}
		[[ ${PV} == *.*.9999 ]] && EGIT_BRANCH=release/${GLIBC_PV%.*}/master
		git-r3_src_unpack
	else
		if use verify-sig; then
			verify-sig_verify_detached "${DISTDIR}/${GLIBC_P}.tar.xz" "${DISTDIR}/${GLIBC_P}.tar.xz.sig"
		fi
		unpack ${GLIBC_P}.tar.xz

		cd "${WORKDIR}" || die
		unpack glibc-${GLIBC_PV}-patches-${PATCH_VER}.tar.xz

		unpack "liblol-${PV}.tar.gz"
	fi

	cd "${WORKDIR}" || die
	use systemd && unpack glibc-systemd-${GLIBC_SYSTEMD_VER}.tar.gz

	ebegin "Removing backported patch from the libLoL patchset"
	rm -f "${WORKDIR}/liblol-${PV}/autobuild/patches/glibc/0001-FROMLIST-LoongArch-Fix-intermittent-nptl-tst-cancel3.patch"
	eend $?
}

# src_prepare

src_prepare() {
	local patchsetname
	if ! use vanilla ; then
		if [[ ${PV} == 9999* ]] ; then
			patchsetname="from git master"
		else
			patchsetname="${GLIBC_PV}-${PATCH_VER}"
		fi
		einfo "Applying Gentoo Glibc patchset ${patchsetname}"
		eapply "${WORKDIR}"/patches
		einfo "Done."

		# Patches we should apply only for Hurd to be conservative
		if is_hurd ; then
			eapply "${FILESDIR}"/glibc-2.43-hurd-CLOCK_MONOTONIC.patch
		fi
	fi

	case ${CTARGET} in
		m68*-aligned-*)
			einfo "Applying utmp format fix for m68k with -maligned-int"
			eapply "${FILESDIR}/glibc-2.41-m68k-malign.patch"
			;;
		*)
			;;
	esac

	einfo "Applying libLoL patchset"
	eapply "${WORKDIR}/liblol-${PV}/autobuild/patches/glibc"
	einfo "Done."

	default

	gnuconfig_update

	cd "${WORKDIR}" || die
	find . -name configure -exec touch {} +

	# Fix permissions on some of the scripts.
	chmod u+x "${S}"/scripts/*.sh

	cd "${S}" || die
}

# src_configure

glibc_do_configure() {
	dump_build_environment

	local myconf=()

	# Use '=strong' instead of '=all' to protect only functions
	# worth protecting from stack smashes.
	myconf+=( --enable-stack-protector=$(usex ssp strong no) )

	# Keep a whitelist of targets supporting IFUNC. glibc's ./configure
	# is not robust enough to detect proper support:
	#    https://bugs.gentoo.org/641216
	#    https://sourceware.org/PR22634#c0
	case $(tc-arch ${CTARGET}) in
		# Keep whitelist of targets where autodetection mostly works.
		amd64|x86|sparc|ppc|ppc64|arm|arm64|s390|riscv|loong) ;;
		# Blacklist everywhere else
		*) myconf+=( libc_cv_ld_gnu_indirect_function=no ) ;;
	esac

	case ${ABI}-${CTARGET} in
		amd64-x86_64-*|x32-x86_64-*-*-gnux32) myconf+=( $(use_enable cet) ) ;;
		*) ;;
	esac

	case ${ABI}-${CTARGET} in
		amd64-x86_64-*|arm64-aarch64-*) myconf+=( $(use_enable sframe) ) ;;
		*) ;;
	esac

	[[ $(tc-is-softfloat) == "yes" ]] && myconf+=( --without-fp )

	myconf+=( --enable-kernel=${MIN_KERN_VER} )

	# Since SELinux support is only required for nscd, only enable it if:
	# 1. USE selinux
	# 2. only for the primary ABI on multilib systems
	# 3. Not a crosscompile
	if ! is_crosscompile && use selinux ; then
		if use multilib ; then
			if is_final_abi ; then
				myconf+=( --with-selinux )
			else
				myconf+=( --without-selinux )
			fi
		else
			myconf+=( --with-selinux )
		fi
	else
		myconf+=( --without-selinux )
	fi

	# Force a few tests where we always know the answer but
	# configure is incapable of finding it.
	if is_crosscompile ; then
		export \
			libc_cv_c_cleanup=yes \
			libc_cv_forced_unwind=yes
	fi

	myconf+=(
		--disable-werror
		--enable-bind-now
		--enable-fortify-source
		--build=${CBUILD_OPT:-${CBUILD}}
		--host=${CTARGET_OPT:-${CTARGET}}
		$(use_enable profile)
		$(use_with gd)
		--with-headers="${ESYSROOT}$(alt_headers)"
		--prefix="$(host_eprefix)/usr"
		--sysconfdir="$(eprefix_lol)/etc"
		--localstatedir="$(eprefix_lol)/var"
		--libdir='$(prefix)'/$(get_libdir)
		--mandir='$(prefix)'/share/man
		--infodir='$(prefix)'/share/info
		--libexecdir='$(libdir)'/misc/glibc
		--with-bugurl=https://github.com/AOSC-Dev/liblol/issues
		--with-pkgversion="$(glibc_banner)"
		$(use_multiarch || echo --disable-multi-arch)
		$(use_enable nscd)

		# /usr/bin/mtrace has a Perl shebang. Gentoo Prefix QA checks fail if
		# Perl hasn't been installed inside the prefix yet and configure picks
		# up a Perl from outside the prefix instead. configure will fail to
		# execute Perl during configure if we're cross-compiling a prefix, but
		# it will just disable mtrace in that case.
		# Note: mtrace is needed by the test suite.
		ac_cv_path_PERL="$(usex perl "${EPREFIX}"/usr/bin/perl $(usex test "${EPREFIX}"/usr/bin/perl $(usex doc "${EPREFIX}"/usr/bin/perl no)))"

		# locale data is arch-independent
		# https://bugs.gentoo.org/753740
		libc_cv_complocaledir='${exec_prefix}/lib/locale'

		# On aarch64 there is no way to override -mcpu=native, and if
		# the current cpu does not support SVE configure fails.
		# Let's boldly assume our toolchain can always build SVE instructions.
		libc_cv_aarch64_sve_asm=yes

		${EXTRA_ECONF}
	)

	# We rely on sys-libs/timezone-data for timezone tools normally.
	myconf+=( $(use_enable vanilla timezone-tools) )

	if is_crosscompile ; then
		myconf+=( --disable-systemtap )
	else
		myconf+=( $(use_enable systemtap) )
	fi

	# These libs don't have configure flags.
	ac_cv_lib_audit_audit_log_user_avc_message=$(usex audit || echo no)
	ac_cv_lib_cap_cap_init=$(usex caps || echo no)

	# There is no configure option for this and we need to export it
	# since the glibc build will re-run configure on itself
	export libc_cv_rootsbindir="$(host_eprefix)/sbin"
	export libc_cv_slibdir="$(host_eprefix)/$(get_libdir)"

	local builddir=$(builddir nptl)
	mkdir -p "${builddir}"
	cd "${builddir}"

	# liblol: set some variables not accessible with configure arguments
	cat > configparms <<EOF
user-defined-trusted-dirs-pre = $(eprefix_lol)/local/$(get_libdir)/preload $(eprefix_lol)/$(get_libdir)/preload
user-defined-trusted-dirs = $(eprefix_lol)/local/$(get_libdir) $(eprefix_lol)/$(get_libdir)
EOF

	set -- "${S}"/configure "${myconf[@]}"
	echo "$@"
	"$@" || die "failed to configure glibc"

	# If we're trying to migrate between ABI sets, we need
	# to lie and use a local copy of gcc.  Like if the system
	# is built with MULTILIB_ABIS="amd64 x86" but we want to
	# add x32 to it, gcc/glibc don't yet support x32.
	#
	if [[ -n ${GCC_BOOTSTRAP_VER} ]] && use multilib-bootstrap ; then
		echo 'int main(void){}' > "${T}"/test.c || die
		if ! $(tc-getCC ${CTARGET}) ${CFLAGS} ${LDFLAGS} "${T}"/test.c -Wl,-emain -lgcc 2>/dev/null ; then
			sed -i -e '/^CC = /s:$: -B$(objdir)/../'"gcc-multilib-bootstrap-${GCC_BOOTSTRAP_VER}/${ABI}:" config.make || die
		fi
	fi
}

glibc_headers_configure() {
	export ABI=default

	local builddir=$(builddir "headers")
	mkdir -p "${builddir}"
	cd "${builddir}"

	# if we don't have a compiler yet, we can't really test it now ...
	# hopefully they don't affect header generation, so let's hope for
	# the best here ...
	local v vars=(
		ac_cv_header_cpuid_h=yes
		libc_cv_{386,390,alpha,arm,hppa,mips,{powerpc,sparc}{,32,64},sh,x86_64}_tls=yes
		libc_cv_asm_cfi_directives=yes
		libc_cv_broken_visibility_attribute=no
		libc_cv_c_cleanup=yes
		libc_cv_compiler_powerpc64le_binary128_ok=yes
		libc_cv_forced_unwind=yes
		libc_cv_gcc___thread=yes
		libc_cv_mlong_double_128=yes
		libc_cv_mlong_double_128ibm=yes
		libc_cv_ppc_machine=yes
		libc_cv_ppc_rel16=yes
		libc_cv_predef_fortify_source=no
		libc_cv_target_power8_ok=yes
		libc_cv_visibility_attribute=yes
		libc_cv_z_combreloc=yes
		libc_cv_z_execstack=yes
		libc_cv_z_initfirst=yes
		libc_cv_z_nodelete=yes
		libc_cv_z_nodlopen=yes
		libc_cv_z_relro=yes
		libc_mips_abi=${ABI}
		libc_mips_float=$([[ $(tc-is-softfloat) == "yes" ]] && echo soft || echo hard)
		# These libs don't have configure flags.
		ac_cv_lib_audit_audit_log_user_avc_message=no
		ac_cv_lib_cap_cap_init=no
	)

	einfo "Forcing cached settings:"
	for v in "${vars[@]}" ; do
		einfo " ${v}"
		export ${v}
	done

	local headers_only_arch_CPPFLAGS=()

	# Blow away some random CC settings that screw things up. #550192
	if [[ -d ${S}/sysdeps/mips ]]; then
		pushd "${S}"/sysdeps/mips >/dev/null
		sed -i -e '/^CC +=/s:=.*:= -D_MIPS_SZPTR=32:' mips32/Makefile mips64/n32/Makefile || die
		sed -i -e '/^CC +=/s:=.*:= -D_MIPS_SZPTR=64:' mips64/n64/Makefile || die

		# Force the mips ABI to the default.  This is OK because the set of
		# installed headers in this phase is the same between the 3 ABIs.
		# If this ever changes, this hack will break, but that's unlikely
		# as glibc discourages that behavior.
		# https://crbug.com/647033
		sed -i -e 's:abiflag=.*:abiflag=_ABIO32:' preconfigure || die

		popd >/dev/null
	fi

	local myconf=()

	case ${CTARGET} in
	aarch64*)
		# The configure checks fail during cross-build, so disable here
		# for headers-only
		myconf+=(
			--disable-mathvec
		) ;;
	riscv*)
		# RISC-V interrogates the compiler to determine which target to
		# build.  If building the headers then we don't strictly need a
		# RISC-V compiler, so the built-in definitions that are provided
		# along with all RISC-V compiler might not exist.  This causes
		# glibc's RISC-V preconfigure script to blow up.  Since we're just
		# building the headers any value will actually work here, so just
		# pick the standard one (rv64g/lp64d) to make the build scripts
		# happy for now -- the headers are all the same anyway so it
		# doesn't matter.
		headers_only_arch_CPPFLAGS+=(
			-D__riscv_xlen=64
			-D__riscv_flen=64
			-D__riscv_float_abi_double=1
			-D__riscv_atomic=1
		) ;;
	esac

	myconf+=(
		--disable-sanity-checks
		--enable-hacker-mode
		--disable-werror
		--enable-bind-now
		--build=${CBUILD_OPT:-${CBUILD}}
		--host=${CTARGET_OPT:-${CTARGET}}
		--with-headers="${ESYSROOT}$(alt_headers)"
		--prefix="$(host_eprefix)/usr"
		${EXTRA_ECONF}
	)

	# Nothing is compiled here which would affect the headers for the target.
	# So forcing CC/CFLAGS is sane.
	local headers_only_CC=$(tc-getBUILD_CC)
	local headers_only_CFLAGS="-O1 -pipe"
	local headers_only_CPPFLAGS="-U_FORTIFY_SOURCE ${headers_only_arch_CPPFLAGS[*]}"
	local headers_only_LDFLAGS=""
	set -- "${S}"/configure "${myconf[@]}"
	echo \
		"CC=${headers_only_CC}" \
		"CFLAGS=${headers_only_CFLAGS}" \
		"CPPFLAGS=${headers_only_CPPFLAGS}" \
		"LDFLAGS=${headers_only_LDFLAGS}" \
		"$@"
	CC=${headers_only_CC} \
	CFLAGS=${headers_only_CFLAGS} \
	CPPFLAGS=${headers_only_CPPFLAGS} \
	LDFLAGS="" \
	"$@" || die "failed to configure glibc"
}

do_src_configure() {
	if just_headers ; then
		glibc_headers_configure
	else
		glibc_do_configure nptl
	fi
}

src_configure() {
	foreach_abi do_src_configure
}

# src_compile

remap_symvers() {
	local file="$1"
	local symvers="$2"

	args=(
		--page-size "$(( 64 * 1024 ))"
		--remap-symvers "$symvers"
		--also-remap-verneed
		"$file"
	)

	patchelf-liblol "${args[@]}" || die
}

lol_build() {
	local path="$1"
	local maketarget="${PWD}/$path"
	local dir="$(dirname -- "$path")"
	local lib="$(basename -- "$path")"
	local emakeargs

	einfo "Building $path"
	case "$lib" in
	libc.so*)
		emakeargs=( "$maketarget" )
		;;
	*)
		emakeargs=(
			-C "${S}/$dir"
			subdir="$dir"
			..=../
			objdir="$PWD"
			"$maketarget"
		)
		;;
	esac

	emake "${emakeargs[@]}"
}

lol_patch() {
	local path="$1"
	local maketarget="${PWD}/$path"
	local lib="$(basename -- "$path")"
	local symvers
	local sv

	local libc_map="GLIBC_2.36=GLIBC_2.27,GLIBC_2.28"
	local pthread_map="GLIBC_2.27=GLIBC_2.0,GLIBC_2.2,GLIBC_2.2.1,GLIBC_2.2.2,GLIBC_2.2.3,GLIBC_2.2.4,GLIBC_2.2.6,GLIBC_2.3,GLIBC_2.3.2,GLIBC_2.3.3,GLIBC_2.3.4,GLIBC_2.4,GLIBC_2.5,GLIBC_2.6,GLIBC_2.7,GLIBC_2.8,GLIBC_2.9,GLIBC_2.10,GLIBC_2.11,GLIBC_2.12,GLIBC_2.13,GLIBC_2.14,GLIBC_2.15,GLIBC_2.16,GLIBC_2.17,GLIBC_2.18,GLIBC_2.19,GLIBC_2.20,GLIBC_2.21,GLIBC_2.22,GLIBC_2.23,GLIBC_2.24,GLIBC_2.25,GLIBC_2.26"

	case "$lib" in
	libc.so*)
		symvers=( "$pthread_map" "$libc_map" )
		;;
	libpthread.so.0)
		symvers=( "$pthread_map" )
		;;
	ld.so.1|libm.so.6|libresolv.so.2|libc_malloc_debug.so.0|libthread_db.so.1|libBrokenLocale.so.1)
		symvers=( "$libc_map" )
		;;
	esac

	[[ ${#symvers[@]} -eq 0 ]] && return

	einfo "Patching ELF symbol versions of $path"
	for sv in "${symvers[@]}"; do
		remap_symvers "$maketarget" "$sv"
	done
}

do_src_compile() {
	local build_order_phase1=(
		libc.so.6
		linkobj/libc.so
	)
	local patch_order_phase1=(
		elf/ld.so.1
		libc.so.6
		linkobj/libc.so
	)
	local build_order_phase2=(
		nptl/libpthread.so.0
		"${LOL_LIBS[@]}"
		"${LOL_MERGED_LIBS[@]}"
	)
	local i

	cd "$(builddir nptl)" || die

	for i in "${build_order_phase1[@]}"; do
		lol_build "$i"
	done
	for i in "${patch_order_phase1[@]}"; do
		lol_patch "$i"
	done

	for i in "${build_order_phase2[@]}"; do
		lol_build "$i"
	done
	for i in "${build_order_phase2[@]}"; do
		lol_patch "$i"
	done

	ebegin "Generating a dummy ld-linux-loongarch-lp64d.so.1"
	$CC -shared \
		-x c /dev/null \
		-o ld-linux-loongarch-lp64d.so.1 \
		-Wl,--version-script -Wl,ld.map \
		-nostdlib \
		$CFLAGS \
		$LDFLAGS
	eend $?
}

src_compile() {
	if just_headers ; then
		return
	fi

	foreach_abi do_src_compile
}

# src_test

glibc_src_test() {
	cd "$(builddir nptl)"

	die "TODO: check abiversions"
}

src_test() {
	if just_headers ; then
		return
	fi

	# glibc_src_test uses nonfatal so that we can run tests for all ABIs
	# and fail at the end instead.
	foreach_abi glibc_src_test || die "tests failed"

}

# src_install

# run_locale_gen is unneeded for liblol

liblol_install() {
	local i
	local files_to_install=(
		libc.so.6
		ld-linux-loongarch-lp64d.so.1
		elf/ld.so.1
		nptl/libpthread.so.0
		"${LOL_LIBS[@]}"
		"${LOL_MERGED_LIBS[@]}"
	)
	local liblol_libdir="$(eprefix_lol)/$(get_libdir)/preload"
	local host_libdir

	if use split-usr; then
		host_libdir="${EPREFIX}/$(get_libdir)"
	else
		host_libdir="${EPREFIX}/usr/$(get_libdir)"
	fi

	dodir "$liblol_libdir"
	for i in "${files_to_install[@]}"; do
		# pwd is builddir
		# the targets are all symlinks, so doins cannot be used
		cp "$i" "${D}${liblol_libdir}/${i##*/}" || die
	done

	dosym -r "${liblol_libdir}/ld.so.1" "${host_libdir}/ld.so.1"

	keepdir "$(eprefix_lol)/local/$(get_libdir)/preload"
}

glibc_do_src_install() {
	local builddir=$(builddir nptl)
	cd "${builddir}"

	liblol_install

	# disabled for liblol
	# This version (2.26) provides some compatibility libraries for the NIS/NIS+ support
	# which come without headers etc. Only needed for binary packages since the
	# external net-libs/libnsl has increased soversion. Keep only versioned libraries.
	#find "${D}" -name "libnsl.a" -delete
	#find "${D}" -name "libnsl.so" -delete

	# Normally upstream_pv is ${PV}. Live ebuilds are exception, there we need
	# to infer upstream version:
	# '#define VERSION "2.26.90"' -> '2.26.90'
	local upstream_pv=$(sed -n -r 's/#define VERSION "(.*)"/\1/p' "${S}"/version.h)

	# Avoid stripping binaries not targeted by ${CHOST}. Or else
	# ${CHOST}-strip would break binaries build for ${CTARGET}.
	is_crosscompile && dostrip -x /

	# gdb thread introspection relies on local libpthreads symbols. stripping breaks it
	# See Note [Disable automatic stripping]
	dostrip -x $(alt_libdir)/libpthread-${upstream_pv}.so
	# valgrind requires knowledge about ld.so symbols.
	dostrip -x $(alt_libdir)/ld-*.so*

	if [[ -e ${ED}/$(alt_usrlibdir)/libm-${upstream_pv}.a ]] ; then
		# Move versioned .a file out of libdir to evade portage QA checks
		# instead of using gen_usr_ldscript(). We fix ldscript as:
		# "GROUP ( /usr/lib64/libm-<pv>.a ..." -> "GROUP ( /usr/lib64/glibc-<pv>/libm-<pv>.a ..."
		sed -i "s@\(libm-${upstream_pv}.a\)@${P}/\1@" \
			"${ED}"/$(alt_usrlibdir)/libm.a || die
		dodir $(alt_usrlibdir)/${P}
		mv "${ED}"/$(alt_usrlibdir)/libm-${upstream_pv}.a \
			"${ED}"/$(alt_usrlibdir)/${P}/libm-${upstream_pv}.a || die
	fi

	# We configure toolchains for standalone prefix systems with a sysroot,
	# which is prepended to paths in ld scripts, so strip the prefix from these.
	# Before: GROUP ( /foo/lib64/libc.so.6 /foo/usr/lib64/libc_nonshared.a  AS_NEEDED ( /foo/lib64/ld-linux-x86-64.so.2 ) )
	# After: GROUP ( /lib64/libc.so.6 /usr/lib64/libc_nonshared.a  AS_NEEDED ( /lib64/ld-linux-x86-64.so.2 ) )
	if [[ -n $(host_eprefix) ]] ; then
		local file
		grep -lZIF "ld script" "${ED}/$(alt_usrlibdir)"/lib*.{a,so} 2>/dev/null | while read -rd '' file ; do
			sed -i "s|$(host_eprefix)/|/|g" "${file}" || die
		done
	fi

	# We'll take care of the cache ourselves
	rm -f "${ED}"/etc/ld.so.cache

	# Everything past this point just needs to be done once ...
	is_final_abi || return 0

	# ld.so handling not needed for liblol

	#################################################################
	# EVERYTHING AFTER THIS POINT IS FOR NATIVE GLIBC INSTALLS ONLY #
	#################################################################

	# Make sure we install some symlink hacks so that when we build
	# a 2nd stage cross-compiler, gcc finds the target system
	# headers correctly.  See gcc/doc/gccinstall.info
	if is_crosscompile ; then
		# We need to make sure that /lib and /usr/lib always exists.
		# gcc likes to use relative paths to get to its multilibs like
		# /usr/lib/../lib64/.  So while we don't install any files into
		# /usr/lib/, we do need it to exist.
		keepdir $(alt_prefix)/lib
		keepdir $(alt_prefix)/usr/lib

		dosym usr/include $(alt_prefix)/sys-include
		return 0
	fi

	# no generation of /usr/share/i18n/SUPPORTED for liblol

	cd "${S}" || die

	# non-essential bits not relevant for liblol

	for d in BUGS ChangeLog CONFORMANCE FAQ NEWS NOTES PROJECTS README* ; do
		[[ -s ${d} ]] && dodoc ${d}
	done
	dodoc -r ChangeLog.old

	# Prevent overwriting of the /etc/localtime symlink.  We'll handle the
	# creation of the "factory" symlink in pkg_postinst().
	rm -f "${ED}"/etc/localtime

	# no locale generation for liblol
}

glibc_headers_install() {
	local builddir=$(builddir "headers")
	cd "${builddir}"
	emake install_root="${D}/$(build_eprefix)$(alt_prefix)" install-headers

	insinto $(alt_headers)/gnu
	doins "${S}"/include/gnu/stubs.h

	# Make sure we install the sys-include symlink so that when
	# we build a 2nd stage cross-compiler, gcc finds the target
	# system headers correctly.  See gcc/doc/gccinstall.info
	dosym usr/include $(alt_prefix)/sys-include
}

src_install() {
	if just_headers ; then
		export ABI=default
		glibc_headers_install
		return
	fi

	foreach_abi glibc_do_src_install

	if ! use static-libs ; then
		einfo "Not installing static glibc libraries"
		find "${ED}" -name "*.a" -and -not -name "*_nonshared.a" -delete
	fi
}

# glibc_sanity_check() not needed for liblol

# pkg_preinst() not needed for liblol

# glibc_refresh_ldconfig not needed for liblol

refresh_lib_symlinks() {
	local liblol_libdir="${EROOT}${LOLPREFIX}/$(get_libdir)/preload"
	local gcc_libs=(
		libatomic.so.1
		libgcc_s.so.1
		libgfortran.so.5
		libgomp.so.1
		libstdc++.so.6
	)
	local gcc_lib
	local lol_lib

	if has_version sys-devel/gcc-config && has_version sys-devel/gcc; then
		local gcc_path="$(gcc-config --get-lib-path 2>/dev/null)"
		# only keep the first entry
		gcc_path="${gcc_path%%:*}"

		einfo "Symlinking GCC libs at $gcc_path to libLoL preload libdir"
		for i in "${gcc_libs[@]}"; do
			gcc_lib="${gcc_path}/$i"
			lol_lib="${liblol_libdir}/$i"

			if ! [[ -f "$gcc_lib" ]]; then
				continue
			fi

			rm -f "$lol_lib"
			ln -s "$gcc_lib" "$lol_lib"
		done
	fi
}

pkg_postinst() {
	# nothing to do if just installing headers
	just_headers && return
	refresh_lib_symlinks

	elog "Because libLoL cannot hook into env-update, you need to manually"
	elog "refresh symlinks after e.g. GCC version changes, by running:"
	elog
	elog "    emerge --config ${CATEGORY}/${PN}"
}

pkg_config() {
	refresh_lib_symlinks
}
