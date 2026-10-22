# Copyright 2017-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit cmake python-single-r1

if [[ ${PV} == 9999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/openSUSE/libsolv.git"
	EGIT_CHECKOUT_DIR=${PN}-${PV}
else
	SRC_URI="https://github.com/openSUSE/libsolv/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Library for solving packages and reading repositories"
HOMEPAGE="https://github.com/openSUSE/libsolv"
LICENSE="GPL-2"
SLOT="0"

IUSE="static perl python ruby tcl rpm pubkey suse comps helix debian mdk arch cudf conda appdata lzma bzip2 zstd zchunk libxml2"

RDEPEND="
	virtual/zlib:=
	bzip2? ( app-arch/bzip2:= )
	lzma? ( app-arch/xz-utils )
	arch? ( app-arch/xz-utils )
	debian? ( app-arch/xz-utils )
	zstd? ( app-arch/zstd:= )
	zchunk? (
		app-arch/zchunk
		app-arch/zstd:=
	)
	libxml2? ( dev-libs/libxml2:= )
	!libxml2? (
		appdata? ( dev-libs/expat )
		comps? ( dev-libs/expat )
		helix? ( dev-libs/expat )
		mdk? ( dev-libs/expat )
		rpm? ( dev-libs/expat )
		suse? ( dev-libs/expat )
	)
	python? ( ${PYTHON_DEPS} )
"
DEPEND="
	perl? ( dev-lang/perl )
	rpm? ( app-arch/rpm )
	ruby? ( dev-lang/ruby )
	tcl? ( dev-lang/tk )
	python? (
		dev-lang/swig
		${PYTHON_DEPS}
	)
"
BDEPEND="${DEPEND}"
DEPEND+=" ${RDEPEND}"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	default
	sed -i -e 's/CMAKE_MINIMUM_REQUIRED (VERSION 3\.5)/CMAKE_MINIMUM_REQUIRED (VERSION 3.10)/' CMakeLists.txt || die
	cmake_prepare
}

src_configure(){
	mycmakeargs=(
		-DCMAKE_C_FLAGS_RELEASE='-DNDEBUG'
		-DENABLE_PERL=$(usex perl)
		-DENABLE_PYTHON=$(usex python)
		-DENABLE_RUBY=$(usex ruby)
		-DENABLE_TCL=$(usex tcl)
		-DUSE_VENDORDIRS=ON
		-DENABLE_RPMDB=$(usex rpm)
		-DENABLE_RPMPKG=$(usex rpm)
		-DENABLE_PUBKEY=$(usex pubkey)
		-DENABLE_RPMDB_BYRPMHEADER=$(usex rpm)
		-DENABLE_RPMDB_LIBRPM=$(usex rpm)
		-DENABLE_RPMDB_BDB=$(usex rpm)
		-DENABLE_RPMPKG_LIBRPM=$(usex rpm)
		-DENABLE_RPMMD=$(usex rpm)
		-DENABLE_SUSEREPO=$(usex suse)
		-DENABLE_COMPS=$(usex comps)
		-DENABLE_HAIKU=OFF
		-DENABLE_HELIXREPO=$(usex helix)
		-DENABLE_DEBIAN=$(usex debian)
		-DENABLE_MDKREPO=$(usex mdk)
		-DENABLE_ARCHREPO=$(usex arch)
		-DENABLE_CUDFREPO=$(usex cudf)
		-DENABLE_CONDA=$(usex conda)
		-DENABLE_APPDATA=$(usex appdata)
		-DMULTI_SEMANTICS=ON
		-DENABLE_LZMA_COMPRESSION=$(usex lzma)
		-DENABLE_BZIP2_COMPRESSION=$(usex bzip2)
		-DENABLE_ZSTD_COMPRESSION=$(usex zstd)
		-DENABLE_ZCHUNK_COMPRESSION=$(usex zchunk)
		-DWITH_SYSTEM_ZCHUNK=$(usex zchunk)
		-DWITH_LIBXML2=$(usex libxml2)
	)
	cmake_src_configure
}
