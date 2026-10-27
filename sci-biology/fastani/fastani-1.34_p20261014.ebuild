# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake

DESCRIPTION="Fast Whole-Genome Similarity (ANI) Estimation"
HOMEPAGE="https://github.com/ParBLiSS/FastANI"
FASTANI_COMMIT_ID="4359b91a0fa8f7c097faf5599b12e232107b36e3"
SRC_URI="https://github.com/ParBLiSS/FastANI/archive/${FASTANI_COMMIT_ID}.tar.gz -> ${P}.tar.gz"

# curl https://api.github.com/repos/ParBLiSS/FastANI/contents/ext/Catch2 | jq -r '.sha'
CATCH2_COMMIT_ID="bcfb10e498df3e2ed8f814b3e4b689b9a85608ab"
SRC_URI+=" https://github.com/catchorg/Catch2/archive/${CATCH2_COMMIT_ID}.tar.gz -> catch2-${CATCH2_COMMIT_ID}.gh.tar.gz"

S="${WORKDIR}/FastANI-${FASTANI_COMMIT_ID}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	sci-libs/gsl:=
	virtual/zlib:=
"
RDEPEND="${DEPEND}"
BDEPEND="${DEPEND}"

src_prepare() {
	rm -rf ext/Catch2
	ln -s "${WORKDIR}/Catch2-${CATCH2_COMMIT_ID}" ext/Catch2
	cmake_src_prepare
}
