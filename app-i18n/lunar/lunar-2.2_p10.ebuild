# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV//_p/-}"

inherit flag-o-matic

DESCRIPTION="Chinese Lunar Calendar conversion utility"
HOMEPAGE="https://packages.debian.org/unstable/utils/lunar"
SRC_URI="https://salsa.debian.org/chinese-team/lunar/-/archive/debian/${MY_PV}/lunar-debian-${MY_PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/lunar-debian-${MY_PV}"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

PATCHES=(
	"${S}/debian/patches/01_strip_trailing_whitespace.diff"
	"${S}/debian/patches/02_fix_compiler_warnings.diff"
	"${S}/debian/patches/03_add_full_path_to_lunar_bitmap.diff"
	"${S}/debian/patches/04_add_big5_and_utf8_output.diff"
	"${S}/debian/patches/05_fix_output_on_year_2033.diff"
	"${S}/debian/patches/06_use_locale_and_current_date.diff"
	"${S}/debian/patches/07_fix_segfault_aggressive-loop-optimizations.diff"
	"${S}/debian/patches/10_complete_the_makefile.diff"
	"${S}/debian/patches/20_update_man_page.diff"
	"${S}/debian/patches/22_datetime-go-back_Zhi.hour_jiealert.patch"
)

src_configure() {
	append-cflags -std=gnu17
	default
}

src_install() {
	dobin lunar
	doman lunar.1
	insinto /usr/share/lunar
	doins lunar.bitmap
}
