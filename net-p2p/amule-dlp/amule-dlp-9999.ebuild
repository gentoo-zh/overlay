# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
WX_GTK_VER="3.2-gtk3"

PYTHON_COMPAT=( python3_{12..15} )

inherit cmake flag-o-matic python-any-r1 wxwidgets xdg git-r3

DESCRIPTION="aMule with DLP patch, the all-platform eMule p2p client"
HOMEPAGE="https://github.com/persmule/amule-dlp"
EGIT_REPO_URI="https://github.com/persmule/amule-dlp"

LICENSE="GPL-2+"
SLOT="0"
IUSE="daemon debug geoip nls remote stats upnp +X"

REQUIRED_USE="|| ( daemon remote X )"

RDEPEND="
	dev-libs/boost:=
	dev-libs/crypto++:=
	net-misc/curl
	sys-libs/binutils-libs:0=
	sys-libs/readline:0=
	virtual/zlib:=
	x11-libs/wxGTK:${WX_GTK_VER}=[curl,X?]
	daemon? (
		acct-user/amule
		dev-libs/glib:2
	)
	geoip? ( dev-libs/libmaxminddb )
	nls? ( virtual/libintl )
	remote? (
		acct-user/amule
		media-libs/libpng:0=
	)
	stats? ( media-libs/gd:=[jpeg,png] )
	upnp? ( net-libs/libupnp:0= )
	X? ( dev-libs/glib:2 )
	!net-p2p/amule
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"

PATCHES=(
	"${FILESDIR}"/amule-dlp-reload-antileech-without-geoip.patch
)

src_configure() {
	setup-wxwidgets

	use debug || append-cppflags -DwxDEBUG_LEVEL=0
	CMAKE_BUILD_TYPE=$(usex debug Debug ${CMAKE_BUILD_TYPE})

	local mycmakeargs=(
		-DAMULE_DLP=YES
		-DBUILD_ALCC=YES
		-DBUILD_ED2K=YES
		-DBUILD_ALC="$(usex X)"
		-DBUILD_AMULECMD="$(usex remote)"
		-DBUILD_DAEMON="$(usex daemon)"
		-DBUILD_CAS="$(usex stats)"
		-DBUILD_MONOLITHIC="$(usex X)"
		-DBUILD_TESTING=NO
		-DBUILD_WEBSERVER="$(usex remote)"
		-DENABLE_BFD=YES
		-DENABLE_IP2COUNTRY="$(usex geoip)"
		-DENABLE_NLS="$(usex nls)"
		-DENABLE_UPNP="$(usex upnp)"
		-DENABLE_VERSION_CHECK=NO
	)

	if use X; then
		mycmakeargs+=(
			-DBUILD_REMOTEGUI="$(usex remote)"
			-DBUILD_WXCAS="$(usex stats)"
		)
	else
		mycmakeargs+=(
			-DBUILD_REMOTEGUI=NO
			-DBUILD_WXCAS=NO
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use daemon; then
		newconfd "${FILESDIR}"/amuled.confd amuled
		newinitd "${FILESDIR}"/amuled.initd amuled
	fi
	if use remote; then
		newconfd "${FILESDIR}"/amuleweb.confd amuleweb
		newinitd "${FILESDIR}"/amuleweb.initd amuleweb
	fi
}
