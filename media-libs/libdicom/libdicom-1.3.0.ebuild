# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="A C library and a set of command-line tools for reading DICOM WSI files"
HOMEPAGE="https://libdicom.readthedocs.io/ https://github.com/ImagingDataCommons/libdicom"
SRC_URI="https://github.com/ImagingDataCommons/libdicom/releases/download/v${PV}/${P}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong"

IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-libs/uthash
	virtual/pkgconfig
	test? ( dev-libs/check )
"

src_configure() {
	local emesonargs=(
		$(meson_use test tests)
	)
	meson_src_configure
}
