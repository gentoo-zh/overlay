# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

inherit cargo

DESCRIPTION="A command line tools for handling mdx related jobs"
HOMEPAGE="https://github.com/raymanzhang/mdx_util"
SRC_URI="
	https://github.com/raymanzhang/mdx_util/archive/068d57bd013ca343ca332c42fada96ee0453e391.tar.gz -> ${P}.tar.gz
	https://github.com/raymanzhang/mdx/archive/111cab6cddb119ce35158ee1a8d641bab698c87e.tar.gz -> mdx.tar.gz
	https://github.com/gentoo-zh-drafts/mdx_util/releases/download/${PV}/${P}-crates.tar.xz
"
SRC_URI+=" ${CARGO_CRATE_URIS}"
S="${WORKDIR}/mdx_util-068d57bd013ca343ca332c42fada96ee0453e391"

LICENSE="AGPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD Boost-1.0 GPL-2 ISC MIT MPL-2.0 Unicode-3.0 ZLIB
	BZIP2
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RUST_MIN_VER="1.88"

src_prepare () {
	mv "${WORKDIR}/mdx-111cab6cddb119ce35158ee1a8d641bab698c87e" "${WORKDIR}/mdx"
	eapply -d "${WORKDIR}/mdx" -- "${FILESDIR}"/${P}-root-locale.patch
	default_src_prepare
}
