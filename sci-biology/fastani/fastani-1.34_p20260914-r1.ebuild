# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake toolchain-funcs

DESCRIPTION="Fast Whole-Genome Similarity (ANI) Estimation"
HOMEPAGE="https://github.com/ParBLiSS/FastANI"
FASTANI_COMMIT_ID="4359b91a0fa8f7c097faf5599b12e232107b36e3"
SRC_URI="https://github.com/ParBLiSS/FastANI/archive/${FASTANI_COMMIT_ID}.tar.gz -> FastANI-${FASTANI_COMMIT_ID}.gh.tar.gz"

S="${WORKDIR}/FastANI-${FASTANI_COMMIT_ID}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	sci-libs/gsl:=
	virtual/zlib:=
"
RDEPEND="${DEPEND}"
BDEPEND="test? ( >=dev-cpp/catch-3:0 )"

PATCHES=( "${FILESDIR}/${PN}-1.34-system-catch2.patch" )

# The D4 genomes are Git LFS objects missing from the release tarball
# (cmake.eclass word-splits the pattern, so "." stands for a space)
CMAKE_SKIP_TESTS=(
	"^Single.Threaded.Multi.Query$"
	"^Single.Threaded.Multi.Ref\\.$"
	"^Single.Threaded.Multi.Q\\..Multi.Ref\\.$"
	"^Multi.Threaded.Multi.Q\\..Multi.Ref\\.$"
	"^Single.Threaded.Multi.Q\\..Multi.Ref\\..Repeats$"
	"^Multi.Threaded.Multi.Q\\..Multi.Ref\\..Repeats$"
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && tc-check-openmp
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}
