# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="ZIM file format: an offline storage solution for content coming from the Web"
HOMEPAGE="https://wiki.openzim.org/wiki/OpenZIM"
SRC_URI="https://github.com/openzim/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc examples +xapian static-libs test"
RESTRICT="!test? ( test )"

RDEPEND="
	virtual/zlib
	app-arch/lzma
	app-arch/xz-utils
	app-arch/zstd
	>=dev-libs/icu-76
	test? ( dev-cpp/gtest )
	xapian? ( >=dev-libs/xapian-1.4.12 )
"

DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local emesonargs=(
		$(meson_use xapian with_xapian)
		$(meson_use doc doc)
		$(meson_use examples examples)
		$(meson_use static-libs static-linkage)
		$(meson_use test tests)
		-Dtest_data_dir=none
	)

	meson_src_configure
}
