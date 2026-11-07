# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )
VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/arnaldocarvalhodemelo.asc
inherit cmake python-single-r1 verify-sig

MY_P="dwarves-${PV}"

DESCRIPTION="pahole/DWARF utilities with CachyOS merged-CU lang_exclude fixes"
HOMEPAGE="https://git.kernel.org/pub/scm/devel/pahole/pahole.git/"
SRC_URI="
	https://fedorapeople.org/~acme/dwarves/${MY_P}.tar.xz
	verify-sig? ( https://fedorapeople.org/~acme/dwarves/${MY_P}.tar.sign )
"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/elfutils-0.178
	virtual/zlib:=
	elibc_musl? (
		sys-libs/obstack-standalone
		sys-libs/argp-standalone
	)
"
DEPEND="${RDEPEND}"
BDEPEND="verify-sig? ( sec-keys/openpgp-keys-arnaldocarvalhodemelo )"

DOCS=( README README.ctracer NEWS )
PATCHES=(
	"${FILESDIR}/${PN}-1.10-python-import.patch"
	"${FILESDIR}/${PN}-1.32-lang-exclude-merged-cu.patch"
)

src_unpack() {
	if use verify-sig; then
		verify-sig_uncompress_verify_unpack "${DISTDIR}/${MY_P}.tar.xz" \
			"${DISTDIR}/${MY_P}.tar.sign"
	else
		default
	fi
}

src_prepare() {
	cmake_src_prepare
	python_fix_shebang ostra/ostra-cg ostra/python/ostra.py
	# Keep upstream's test fixtures inside the Portage sandbox.
	sed -i 's|test_master_dir="/tmp/pahole-tests"|test_master_dir="${TMPDIR:-/tmp}/pahole-tests"|' \
		tests/test_lib.sh || die
}

src_configure() {
	local mycmakeargs=(
		# Install under a private prefix: this package coexists with
		# sys-kernel/cachyos-*'s in-kernel pahole shim instead of
		# competing for /usr/bin/pahole with dev-util/pahole.
		-DCMAKE_INSTALL_PREFIX=/usr/libexec/pahole-cachyos
	)
	cmake_src_configure
}

src_test() {
	local -x PATH="${BUILD_DIR}:${PATH}" TMPDIR="${T}"
	local regression rc
	for regression in lang_exclude_merged_cu lang_exclude_lto_refs; do
		sh "${S}/tests/${regression}.sh"
		rc=$?
		# Exit status 2 is upstream's test_skip (missing gcc/clang/lld).
		if [[ ${rc} -eq 2 ]]; then
			ewarn "${regression} skipped"
		elif [[ ${rc} -ne 0 ]]; then
			die "${regression} failed"
		fi
	done
}

pkg_postinst() {
	elog "This pahole lives in /usr/libexec/pahole-cachyos/bin and is not on PATH."
	elog "sys-kernel/cachyos-sources and cachyos-kernel patch the kernel Makefile"
	elog "to call it directly (PAHOLE = /usr/libexec/pahole-cachyos/bin/pahole),"
	elog "so Rust + LTO + BTF kernels and their external modules get the"
	elog "merged-CU --lang_exclude fixes without touching dev-util/pahole."
}
