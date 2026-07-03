# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools flag-o-matic

DESCRIPTION="PCMan is a gtk+ based free BBS client"
HOMEPAGE="https://github.com/pcman-bbs/pcmanx"
SRC_URI="https://github.com/pcman-bbs/pcmanx/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+libnotify +proxy iplookup +wget"

COMMON_DEPEND="
	libnotify? ( x11-libs/libnotify )
	x11-libs/libXft
	>=x11-libs/gtk+-2.4:2
"

RDEPEND="
	${COMMON_DEPEND}
	wget? ( net-misc/wget )
"

DEPEND="
	${COMMON_DEPEND}
	dev-util/intltool
	sys-devel/gettext
"

DOCS=( TODO README NEWS ChangeLog AUTHORS )

src_prepare() {
	eautoreconf

	# this flag crashes CTermData::memset16()
	filter-flags -ftree-vectorize
	eapply_user
}

src_configure() {
	econf $(use_enable proxy) \
		$(use_enable libnotify) \
		$(use_enable wget)\
		$(use_enable iplookup)
}
