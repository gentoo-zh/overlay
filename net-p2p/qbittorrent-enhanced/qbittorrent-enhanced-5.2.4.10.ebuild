# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_IN_SOURCE_BUILD=ON

inherit cmake systemd xdg

DESCRIPTION="qBittorrent Enhanced, based on qBittorrent"
HOMEPAGE="https://github.com/c0re100/qBittorrent-Enhanced-Edition"

SRC_URI="https://github.com/c0re100/qBittorrent-Enhanced-Edition/archive/release-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/qBittorrent-Enhanced-Edition-release-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+dbus webui +gui"

REQUIRED_USE="dbus? ( gui )
	|| ( gui webui )
"

RDEPEND="
	>=dev-libs/boost-1.65.0-r1:=
	dev-libs/openssl:=
	net-libs/libtorrent-rasterbar
	virtual/zlib
	dev-libs/geoip

	dev-qt/qtbase:6[network,ssl,sql,xml]
	gui? (
		dev-qt/qtbase:6[gui,widgets]
		dev-qt/qtsvg:6
	)
	dbus? ( dev-qt/qtbase:6[dbus] )

"
DEPEND="${RDEPEND}"
BDEPEND="dev-qt/qttools:6
		virtual/pkgconfig"

DOCS=(AUTHORS Changelog CONTRIBUTING.md README.md)

src_configure() {
	set enable_gui="OFF"
	if use gui; then
		enable_gui="ON"
	fi

	local mycmakeargs=(
		-DDBUS=$(usex dbus)
		-DWEBUI=$(usex webui)
		-DGUI=$(usex gui)

		-DSYSTEMD=ON
		-DSYSTEMD_SERVICES_INSTALL_DIR=$(systemd_get_systemunitdir)

		-DVERBOSE_CONFIGURE=ON

	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	einstalldocs
}
