# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 desktop pypi

DESCRIPTION="A user-friendly and hackable music player"
HOMEPAGE="https://github.com/feeluown/FeelUOwn"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+netease +qqmusic +ytmusic +bilibili +cookies qt6 webengine"
RESTRICT="test" # TODO

RDEPEND="
	dev-python/janus[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/qasync[${PYTHON_USEDEP}]
	dev-python/tomlkit[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.10[${PYTHON_USEDEP}]
	>=dev-python/fluent-runtime-0.4.0[${PYTHON_USEDEP}]
	media-libs/mutagen[${PYTHON_USEDEP}]
"

PDEPEND="
	media-video/mpv[libmpv]
	netease? ( dev-python/fuo-netease[${PYTHON_USEDEP}] )
	qqmusic? ( dev-python/fuo-qqmusic[${PYTHON_USEDEP}] )
	bilibili? ( dev-python/feeluown-bilibili[$PYTHON_USEDEP] )
	ytmusic? ( dev-python/fuo-ytmusic[$PYTHON_USEDEP] )
	cookies? ( net-misc/yt-dlp )
	qt6? ( dev-python/pyqt6[gui,widgets,opengl,svg,${PYTHON_USEDEP}] )
	webengine? ( dev-python/pyqt6-webengine[$PYTHON_USEDEP] )
"

PATCHES=(
	"${FILESDIR}"/${PN}-5.0.2-remove-examples.patch
)

python_install_all() {
	distutils-r1_python_install_all

	domenu "${FILESDIR}/${PN}.desktop"
	newicon "${S}/feeluown/gui/assets/icons/feeluown.png" "${PN}.png"
}
