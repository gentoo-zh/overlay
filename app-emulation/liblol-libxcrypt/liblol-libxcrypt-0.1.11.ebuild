# Copyright 2004-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
# NEED_BOOTSTRAP is for developers to quickly generate a tarball
# for publishing to the tree.
NEED_BOOTSTRAP="no"
inherit crossdev multibuild multilib python-any-r1 flag-o-matic toolchain-funcs multilib-minimal

# upstream metadata
XC_PV="4.4.38"
XC_P="libxcrypt-${XC_PV}"

# liblol additions
LOLPREFIX=/opt/lol

DESCRIPTION="libxcrypt for liblol"
HOMEPAGE="https://github.com/besser82/libxcrypt https://liblol.aosc.io"
if [[ ${NEED_BOOTSTRAP} == "yes" ]] ; then
	inherit autotools
	SRC_URI="https://github.com/besser82/libxcrypt/releases/download/v${XC_PV}/${XC_P}.tar.xz"
else
	SRC_URI="https://dev.gentoo.org/~sam/distfiles/sys-libs/libxcrypt/${XC_P}-autotools.tar.xz"
fi

S="${WORKDIR}/libxcrypt-${XC_PV}"
LICENSE="LGPL-2.1+ public-domain BSD BSD-2"
SLOT="0/1"
#KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
KEYWORDS="-* ~loong"
IUSE="static-libs test headers-only"
RESTRICT="!test? ( test )"

DEPEND="
	elibc_glibc? (
		sys-libs/glibc[-crypt(-)]
		!sys-libs/glibc[crypt(-)]
	)
	elibc_musl? (
		sys-libs/musl[-crypt(+)]
		!sys-libs/musl[crypt(+)]
	)
"
RDEPEND="${DEPEND}
	!<sys-apps/man-pages-6.16-r1
"
BDEPEND="
	dev-lang/perl
	>=dev-util/patchelf-liblol-0.1.9
	test? ( $(python_gen_any_dep 'dev-python/libpass[${PYTHON_USEDEP}]') )
"

python_check_deps() {
	python_has_version "dev-python/libpass[${PYTHON_USEDEP}]"
}

pkg_pretend() {
	if has "distcc" ${FEATURES} ; then
		ewarn "Please verify all distcc nodes are using the same versions of GCC (>= 10) and Binutils!"
		ewarn "Older/mismatched versions of GCC may lead to a misbehaving library: bug #823179."

		if [[ ${BUILD_TYPE} != "binary" ]] && tc-is-gcc && [[ $(gcc-major-version) -lt 10 ]] ; then
			die "libxcrypt is known to fail to build or be broken at runtime with < GCC 10 (bug #823179)!"
		fi
	fi
}

pkg_setup() {
	:
}

src_prepare() {
	default

	# WARNING: Please read on bumping or applying patches!
	#
	# There are two circular dependencies to be aware of:
	# 1)
	#	if we're bootstrapping configure and makefiles:
	#		libxcrypt -> automake -> perl -> libxcrypt
	#
	#   mitigation:
	#		toolchain@ manually runs `make dist` after running autoconf + `./configure`
	#		and the ebuild uses that.
	#		(Don't include the pre-generated Perl artefacts.)
	#
	#	solution for future:
	#		Upstream are working on producing `make dist` tarballs.
	#		https://github.com/besser82/libxcrypt/issues/134#issuecomment-871833573
	#
	# 2)
	#	configure *unconditionally* needs Perl at build time to generate
	#	a list of enabled algorithms based on the set passed to `configure`:
	#		libxcrypt -> perl -> libxcrypt
	#
	#	mitigation:
	#		None at the moment.
	#
	#	solution for future:
	#		Not possible right now. Upstream intend on depending on Perl for further
	#		configuration options.
	#		https://github.com/besser82/libxcrypt/issues/134#issuecomment-871833573
	#
	# Therefore, on changes (inc. bumps):
	#	* You must check whether upstream have started providing tarballs with bootstrapped
	#	  auto{conf,make};
	#
	#	* diff the build system changes!
	#
	if [[ ${NEED_BOOTSTRAP} == "yes" ]] ; then
		# Facilitate our split variant build for compat + non-compat
		eapply "${FILESDIR}"/libxcrypt-4.4.19-multibuild.patch
		eautoreconf
	fi
}

src_configure() {
	MULTIBUILD_VARIANTS=(
		xcrypt_liblol
	)

	MYPREFIX=${EPREFIX}
	MYSYSROOT=${ESYSROOT}

	if target_is_not_host; then
		# Hack to work around missing TARGET_CC support.
		# See bug 949976.
		if tc-is-clang; then
			export CC="${CTARGET}-clang"
		else
			export CC="${CTARGET}-gcc"
		fi

		local CHOST=${CTARGET}

		MYPREFIX=
		MYSYSROOT=${ESYSROOT}/usr/${CTARGET}

		# Ensure we get compatible libdir
		unset DEFAULT_ABI MULTILIB_ABIS
		multilib_env
		ABI=${DEFAULT_ABI}

		strip-unsupported-flags
	fi

	if use headers-only; then
		# Nothing is compiled which would affect the headers, so we set
		# CC and PKG_CONFIG to ensure configure passes without defaulting
		# to the unprefixed host variants e.g. "pkg-config"
		local -x CC="$(tc-getBUILD_CC)"
		local -x PKG_CONFIG="false"
	fi

	# Doesn't work with LTO: bug #852917.
	# https://github.com/besser82/libxcrypt/issues/24
	filter-lto

	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	if use test; then
		python_setup
	fi

	multibuild_foreach_variant multilib-minimal_src_configure
}

multilib_src_configure() {
	local myconf=(
		--disable-werror
		--prefix="${MYPREFIX}/usr"
		--libdir="${MYPREFIX}/usr/$(get_libdir)"
		--includedir="${MYPREFIX}/usr/include"
		--with-pkgconfigdir="${MYPREFIX}/usr/$(get_libdir)/pkgconfig"
		--with-sysroot="${MYSYSROOT}"
	)

	tc-export PKG_CONFIG

	case "${MULTIBUILD_ID}" in
		xcrypt_liblol-*)
			myconf+=(
				--disable-static
				--enable-shared
				--disable-xcrypt-compat-files
				--enable-obsolete-api=glibc
			)
			;;

		*) die "Unexpected MULTIBUILD_ID: ${MULTIBUILD_ID}";;
	esac

	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

src_compile() {
	use headers-only && return

	multibuild_foreach_variant multilib-minimal_src_compile
}

multilib_src_compile() {
	rm -f crypt-symbol-vers.h crypt-symbol-vers.h.stamp
	emake libcrypt.la SYMVER_FLOOR=GLIBC_2.27

	patchelf-liblol \
		--page-size "$(( 64 * 1024 ))" \
		--remap-symvers "GLIBC_2.36=GLIBC_2.27,GLIBC_2.28" \
		.libs/libcrypt.so.1 || die

	patchelf-liblol \
		--page-size "$(( 64 * 1024 ))" \
		--replace-needed "ld-linux-loongarch-lp64d.so.1" "ld.so.1" \
		.libs/libcrypt.so.1 || die
}

multilib_src_test() {
	die "TODO: check abiversion"
}

src_test() {
	multibuild_foreach_variant multilib-minimal_src_test
}

src_install() {
	local DESTDIR=${D}
	if target_is_not_host; then
		DESTDIR=${ED}/usr/${CTARGET}
	fi

	multibuild_foreach_variant multilib-minimal_src_install

	find "${ED}" -name '*.la' -delete || die

	if target_is_not_host; then
		insinto /usr/${CTARGET}/usr/share
		doins -r "${ED}/usr/share/doc"
		rm -r "${ED}/usr/share/doc" || die
		rmdir "${ED}/usr/share" || die
	fi
}

multilib_src_install() {
	if use headers-only; then
		die "not supposed to happen for liblol builds"
	fi

	local liblol_libdir
	liblol_libdir="$EPREFIX$LOLPREFIX/$(get_libdir)/preload"
	into "$liblol_libdir"

	# pwd is builddir
	# the targets are all symlinks, so doins cannot be used
	cp .libs/libcrypt.so.1 "${D}${liblol_libdir}/libcrypt.so.1" || die
}

# pkg_preinst() dropped for liblol
