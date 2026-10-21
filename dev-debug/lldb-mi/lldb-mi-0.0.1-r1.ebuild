# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {19..22} )

inherit cmake llvm-r2

DESCRIPTION="LLDB Machine Interface Driver"
HOMEPAGE="https://github.com/lldb-tools/lldb-mi"
SRC_URI="
	https://github.com/lldb-tools/lldb-mi/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="Apache-2.0-with-LLVM-exceptions"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	$(llvm_gen_dep '
		=llvm-core/lldb-${LLVM_SLOT}*:=
		llvm-core/llvm:${LLVM_SLOT}=
	')
"
RDEPEND="${DEPEND}"

PATCHES=(
	# CMake 4 no longer accepts cmake_minimum_required < 3.5
	"${FILESDIR}"/${P}-cmake4.patch
)
