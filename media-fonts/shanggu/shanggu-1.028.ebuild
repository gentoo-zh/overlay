# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font unpacker

DESCRIPTION="A Noto-based font for traditional Chinese characters"
HOMEPAGE="https://github.com/GuiWonder/Shanggu"

MY_PN="Shanggu"

SRC_URI="
	mono? ( https://github.com/GuiWonder/${MY_PN}/releases/download/${PV}/${MY_PN}MonoTTFs.7z -> ${MY_PN}Mono-${PV}.7z )
	round? (
		https://github.com/GuiWonder/${MY_PN}/releases/download/${PV}/${MY_PN}RoundTTFs.7z
			-> ${MY_PN}Round-${PV}.7z
	)
	sans? ( https://github.com/GuiWonder/${MY_PN}/releases/download/${PV}/${MY_PN}SansTTFs.7z -> ${MY_PN}Sans-${PV}.7z )
	serif? (
		https://github.com/GuiWonder/${MY_PN}/releases/download/${PV}/${MY_PN}SerifTTFs.7z
			-> ${MY_PN}Serif-${PV}.7z
	)
	variant? (
			 https://github.com/GuiWonder/${MY_PN}/releases/download/${PV}/${MY_PN}SansVF_TTFs.7z -> ${MY_PN}SansVF-${PV}.7z
			 https://github.com/GuiWonder/${MY_PN}/releases/download/${PV}/${MY_PN}SerifVF_TTFs.7z -> ${MY_PN}SerifVF-${PV}.7z
			 )
"

S="${WORKDIR}"
LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="round sans +serif mono variant"
REQUIRED_USE="|| ( round sans serif mono variant )"
BDEPEND="
	$(unpacker_src_uri_depends)
"

FONT_CONF=( "${FILESDIR}/70-shanggu.conf" )
FONT_SUFFIX="ttf"

src_unpack() {
	use mono && unpack_7z "${MY_PN}Mono-${PV}.7z"
	use round && unpack_7z "${MY_PN}Round-${PV}.7z"
	use sans && unpack_7z "${MY_PN}Sans-${PV}.7z"
	use serif && unpack_7z "${MY_PN}Serif-${PV}.7z"
	use variant && { unpack_7z "${MY_PN}SansVF-${PV}.7z"
					 unpack_7z "${MY_PN}SerifVF-${PV}.7z"
					}
}

src_install() {
	FONT_S=()

	if use serif; then
		FONT_S+=(
			"${S}/${MY_PN}Serif"
			"${S}/${MY_PN}SerifTC"
			"${S}/${MY_PN}SerifSC"
			"${S}/${MY_PN}SerifJP"
			"${S}/${MY_PN}SerifST"
		)
	fi

	if use sans; then
		FONT_S+=(
			"${S}/${MY_PN}Sans"
			"${S}/${MY_PN}SansJP"
			"${S}/${MY_PN}SansTC"
			"${S}/${MY_PN}SansSC"
			"${S}/${MY_PN}SansST"
		)
	fi

	if use mono; then
		FONT_S+=(
			"${S}/${MY_PN}Mono"
			"${S}/${MY_PN}MonoSC"
			"${S}/${MY_PN}MonoTC"
			"${S}/${MY_PN}MonoJP"
		)
	fi

	if use round; then
		FONT_S+=(
			"${S}/${MY_PN}Round"
			"${S}/${MY_PN}RoundSC"
			"${S}/${MY_PN}RoundTC"
			"${S}/${MY_PN}RoundJP"
			"${S}/${MY_PN}RoundST"
		)
	fi

	if use variant; then
		FONT_S+=( "${S}" )
	fi

	font_src_install
}
