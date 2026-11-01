# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PLOCALES="
	ar ay be bg crowdin cs de de_CH el en eo es es_AR es_BO
	fa fi fr hi hu ie it ja jbo kab ko lt mk nl pl pt pt_BR
	qu ru sk sq sr sv tg tk tr uk vi zh_CN zh_TW
"
PLOCALE_BACKUP="en"

inherit cmake flag-o-matic plocale xdg

DESCRIPTION="Feature-rich dictionary lookup program (qtwebengine fork)"
HOMEPAGE="https://xiaoyifang.github.io/goldendict-ng/"
SRC_URI="
	https://github.com/xiaoyifang/goldendict-ng/archive/v${PV}.tar.gz -> ${PN}-ng-${PV}.tar.gz
"
S="${WORKDIR}/goldendict-ng-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="epwing +tts +X zim"
# Actual min ver is 6.2
# FFMPEG Player is not supported for Qt >= 6.8
# Gentoo MainTree dropped last version of QT6.8 on 2025/07/10
QT_MIN="6.8"
QTBASE_USE="dbus,concurrent,cups,gui,network,sql,widgets,xml,X?"

DEPEND="
	app-arch/bzip2
	app-arch/lzma
	app-arch/xz-utils
	app-i18n/opencc:=
	app-text/hunspell:=
	dev-cpp/tomlplusplus
	dev-libs/libfmt:=
	dev-libs/lzo:2
	dev-libs/xapian:=
	>=dev-qt/qt5compat-${QT_MIN}:6
	>=dev-qt/qtbase-${QT_MIN}:6[${QTBASE_USE}]
	>=dev-qt/qtmultimedia-${QT_MIN}:6
	>=dev-qt/qtdeclarative-${QT_MIN}:6
	>=dev-qt/qtsvg-${QT_MIN}:6
	>=dev-qt/qtwebchannel-${QT_MIN}:6
	>=dev-qt/qtwebengine-${QT_MIN}:6[widgets]
	epwing? ( dev-libs/eb )
	media-libs/libvorbis
	tts? ( >=dev-qt/qtspeech-${QT_MIN}:6 )
	virtual/zlib:=
	virtual/opengl
	virtual/libiconv
	X? (
		x11-libs/libX11
		x11-libs/libxkbcommon
		x11-libs/libXtst
	)
	zim? ( app-arch/libzim )
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-qt/qttools-${QT_MIN}:6[assistant,linguist]
	virtual/pkgconfig
"

src_prepare() {
	local loc_dir="${S}/locale"
	plocale_find_changes "${loc_dir}" "" ".ts"
	rm_loc() { rm -vf "locale/${1}.ts" || die ;}
	plocale_for_each_disabled_locale rm_loc

	cmake_src_prepare
}

src_configure() {
	# stack overfow & std::bad_alloc on musl
	use elibc_musl && append-ldflags -Wl,-z,stack-size=2097152

	local mycmakeargs=(
		#FFMPEG Player is useless for Qt >= 6.8
		-DWITH_FFMPEG_PLAYER=OFF
		-DWITH_QT_MULTIMEDIA=ON
		-DWITH_EPWING_SUPPORT=$(usex epwing ON OFF)
		-DWITH_TTS=$(usex tts ON OFF)
		-DWITH_ZIM=$(usex zim ON OFF)
		-DWITH_VCPKG_BREAKPAD=OFF
		-DWITH_X11=$(usex X ON OFF)
	)
	cmake_src_configure
}
