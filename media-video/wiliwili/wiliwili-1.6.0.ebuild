# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake flag-o-matic xdg

DESCRIPTION="跨平台第三方B站客户端"
HOMEPAGE="
	https://www.xfangfang.cn/wiliwili/
	https://github.com/xfangfang/wiliwili
"
SRC_URI="
	https://github.com/xfangfang/wiliwili/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
"

SUBMODULES=(
	"MemoryModule main https://github.com/xfangfang/MemoryModule 7739ba4b2d87395446bbdcad6ae8bf9131b4250b"
	#"OpenCC main https://github.com/xfangfang/OpenCC ccae908834c2fe41ba02141fa5d0eef178a45080"
	#"QR-Code-generator main https://github.com/nayuki/QR-Code-generator 720f62bddb7226106071d4728c292cb1df519ceb"
	"borealis main https://github.com/xfangfang/borealis 5f08b286f3df737f3321d2247a6fe633fcead03c"
	"cpr main https://github.com/xfangfang/cpr ef35a614f1feb6ba0d4de13b1950bcaf7faad060"
	"libpdr main https://github.com/xfangfang/libpdr 9dd3ab920940adac013a3cf40e3a5805d7e193e1"
	"lunasvg main https://github.com/sammycage/lunasvg f924651b85cac47dbe15f51a4aa320461fc1d07b"
	"mongoose main https://github.com/xfangfang/mongoose 4328842400370f62d00b6a6b23f1cbe0cded4073"
	#"pystring main https://github.com/imageworks/pystring 7d16bc814ccb4cad03c300dcb77440034caa84f7"

	"glfw borealis https://github.com/xfangfang/glfw 892256c3f630739fb02552544b8d83240883ec8a"
	#"SDL borealis https://github.com/libsdl-org/SDL 15ead9a40d09a1eb9972215cceac2bf29c9b77f6"
)

LICENSE="GPL-3"
# MemoryModule -> MPL-2.0
# OpenCC, borealis -> Apache-2.0
# QR-Code-generator, cpr, lunasvg -> MIT
# mongoose -> GPL-2
# pystring -> BSD-3-Clause
# glfw -> zlib
LICENSE+=" MPL-2.0 Apache-2.0 MIT GPL-2 BSD ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="glfw +hwaccel opencc +sdl2 +webp wayland +X"
REQUIRED_USE="
	|| ( wayland X )
	^^ ( glfw sdl2 )
"
RESTRICT="test"

DEPEND="
	opencc? ( app-i18n/opencc:= )
	dev-cpp/pystring:=
	dev-libs/libfmt:=
	dev-libs/openssl:=
	dev-libs/qr-code-generator:=
	dev-libs/tinyxml2:=
	sdl2? (
		media-libs/libsdl2[wayland?,X?]
	)
	glfw? ( sys-apps/dbus )
	webp? ( media-libs/libwebp:= )
	media-video/mpv:=[libmpv]
	net-misc/curl
	virtual/zlib:=
"
RDEPEND="${DEPEND}"
BDEPEND="
	glfw? (
		wayland? (
			dev-libs/wayland-protocols
		)
		X? (
			x11-libs/libXi
			x11-libs/libXinerama
		)
	)
"

CMAKE_QA_COMPAT_SKIP=1

submodule_uris() {
	for line in "${SUBMODULES[@]}"; do
		read -r dep proj url commit <<< "${line}" || die
		SRC_URI+=" ${url}/archive/${commit}.tar.gz -> ${url##*/}-${commit}.tar.gz"
	done
}

submodule_uris

pkg_pretend() {
	if ! use hwaccel; then
		ewarn "USE=hwaccel not set, using software rendering, but it will affect performance."
	else
		ewarn "USE=hwaccel set, if your system does not support OpenGL(ES), this is useless."
	fi
}

src_prepare() {
	for line in "${SUBMODULES[@]}"; do
		read -r dep proj url commit <<< "${line}" || die

		if [[ ${proj} == "main" ]]; then
			cp -r "${WORKDIR}"/${url##*/}-${commit}/* "${S}/library/${dep}/" || die
		elif [[ ${proj} == "borealis" ]]; then
			cp -r "${WORKDIR}"/${url##*/}-${commit}/* "${S}/library/borealis/library/lib/extern/${dep}/" || die
		else
			die
		fi
	done
	cmake_src_prepare
}

src_configure() {
	# LTO fails in subproject libpdr with ODR violations[-Werror=odr]
	filter-lto

	local mycmakeargs=(
		-DPLATFORM_DESKTOP=ON
		-DINSTALL=ON
		-DUSE_SDL2=$(usex sdl2 ON OFF)
		-DUSE_GLFW=$(usex glfw ON OFF)
		-DMPV_SW_RENDER=$(usex !hwaccel ON OFF)
		#-DMPV_NO_FB=$(usex !framebuffer ON OFF)

		-DGIT_TAG_VERSION="${PV}"
		-DGIT_TAG_SHORT="${PV}"

		-DUSE_SHARED_LIB=ON
		-DUSE_SYSTEM_CURL=ON
		-DUSE_SYSTEM_CPR=OFF # not packaged
		-DUSE_SYSTEM_QRCODEGEN=ON
		-DUSE_SYSTEM_PYSTRING=ON
		-DUSE_SYSTEM_OPENCC=ON
		-DUSE_SYSTEM_FMT=ON
		-DUSE_SYSTEM_TINYXML2=ON
		-DUSE_SYSTEM_SDL2=ON
		-DUSE_SYSTEM_MONGOOSE=OFF # not packaged
		-DUSE_SYSTEM_LUNASVG=OFF # not packaged
		-DUSE_SYSTEM_GLFW=OFF # modified GLFW used

		-DUSE_SYSTEM_TWEENY=OFF # not packaged

		-DDISABLE_OPENCC=$(usex !opencc ON OFF)
		-DDISABLE_WEBP=$(usex !webp ON OFF)
	)
	if use glfw; then
		mycmakeargs+=(
			-DGLFW_BUILD_WAYLAND=$(usex wayland ON OFF)
			-DGLFW_BUILD_X11=$(usex X ON OFF)
		)
	fi
	cmake_src_configure
}
