# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {20..22} )
LLVM_OPTIONAL=1

inherit unpacker ninja-utils llvm-r1 toolchain-funcs check-reqs

DESCRIPTION="The Dart SDK"
HOMEPAGE="https://dart.dev https://github.com/dart-lang/sdk"
# repack sdk by "abuild snapshot"
# https://github.com/alpinelinux/aports/blob/master/testing/dart/APKBUILD
# cookbook: https://lingchengling.feishu.cn/docx/VIkqdR04koXb1exOqmbcSz2DnZe
SRC_URI="
	https://github.com/gentoo-zh-drafts/dart-sdk-repack/releases/download/${PV}/dart-sdk-${PV}.tar.zst
"

S="${WORKDIR}/dart-sdk-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~amd64"
CHECKREQS_DISK_BUILD="15G"

IUSE="clang"
REQUIRED_USE="clang? ( ${LLVM_REQUIRED_USE} )"

BDEPEND="
	>=dev-lang/dart-bootstrap-3.12.2
	dev-build/gn
	dev-build/ninja
	dev-vcs/git
	clang? (
		$(llvm_gen_dep '
			llvm-core/clang:${LLVM_SLOT}
			llvm-core/lld:${LLVM_SLOT}
			llvm-runtimes/compiler-rt-sanitizers:${LLVM_SLOT}
		')
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-3.10.2-fix_toolchain_prefix.patch"
	"${FILESDIR}/${PN}-3.10.2-use_system_clang.patch"
	"${FILESDIR}/${PN}-3.10.2-use_lld_when_using_clang.patch"
	"${FILESDIR}/${PN}-3.10.2-custom_flags.patch"
	"${FILESDIR}/${PN}-3.12.2-no-werror.patch"
)

src_prepare() {
	# https://github.com/dart-lang/sdk/issues/52295
	# needed by build.ninja.stamp
	mkdir -pv .git/logs
	touch .git/logs/HEAD

	ln -sfv "${BROOT}"/usr/lib/dart-bootstrap tools/sdks/dart-sdk

	# needed by tools/build.py
	# ln -sfv /usr/bin/gn buildtools/gn
	# mkdir -p buildtools/ninja
	# ln -sfv /usr/bin/ninja buildtools/ninja/ninja

	python3 tools/generate_package_config.py
	python3 tools/generate_sdk_version_file.py

	default
}

src_configure() {
	local mygnargs=()
	mygnargs+=( 'target_cpu="x64"' )
	mygnargs+=( "is_clang=$(usex clang true false)" )
	mygnargs+=( 'is_debug=false' )
	mygnargs+=( 'is_release=true' )
	mygnargs+=( 'dart_platform_sdk=false' )
	mygnargs+=( 'verify_sdk_hash=false' )
	use clang && mygnargs+=( "clang_toolchain_dir=\"$(get_llvm_prefix)/bin\"" )
	gn gen --args="${mygnargs[*]}" out/Release
}

src_compile() {
	# fix can't find cc1plus
	export PATH=/usr/libexec/gcc/${CHOST}/$(gcc-major-version)/:$PATH
	local myninjaargs=""
	# The create_sdk ninja argument can also build bin/dart and bin/dartaotruntime.
	# disabling the runtime ninja argument can reduce time and space usage.
	# myninjaargs+=" runtime"
	myninjaargs+=" create_sdk"
	eninja ${myninjaargs} -C out/Release
}

src_install() {
	insinto /usr/lib/dart
	doins -r out/Release/dart-sdk/*

	fperms +x /usr/lib/dart/bin/dart
	fperms +x /usr/lib/dart/bin/dartaotruntime
	fperms +x /usr/lib/dart/bin/dartaotruntime_asan
	fperms +x /usr/lib/dart/bin/dartaotruntime_tsan
	use clang && fperms +x /usr/lib/dart/bin/dartaotruntime_msan
	fperms +x /usr/lib/dart/bin/utils/gen_snapshot
	fperms +x /usr/lib/dart/bin/utils/wasm-opt

	dosym ../lib/dart/bin/dart /usr/bin/dart
	dosym ../lib/dart/bin/dartaotruntime /usr/bin/dartaotruntime
}
