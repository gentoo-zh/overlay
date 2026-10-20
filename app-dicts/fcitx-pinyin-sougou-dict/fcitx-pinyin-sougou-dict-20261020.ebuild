# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="fcitx5-pinyin-sougou-dict"

DESCRIPTION="Sougou Pinyin dictionary for Fcitx5 and RIME"
HOMEPAGE="https://github.com/blackteahamburger/fcitx5-pinyin-sougou-dict"
SRC_URI="
	https://github.com/blackteahamburger/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/blackteahamburger/${MY_PN}/releases/download/${PV}/sougou_dict.tar.gz
		-> sougou_dict-${PV}.tar.gz
"

S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="Unlicense"
SLOT="5"
KEYWORDS="~amd64"
IUSE="+fcitx rime"
REQUIRED_USE="|| ( fcitx rime )"

RDEPEND="
	fcitx? ( app-i18n/fcitx:5 )
	rime? ( || ( app-i18n/ibus-rime app-i18n/fcitx-rime ) )
"
BDEPEND="
	fcitx? ( app-i18n/libime:5 )
	>=app-text/imewlconverter-3.4.3
"

src_unpack() {
	default
	cp -r "${WORKDIR}/sougou_dict" "${S}" || die
}

src_compile() {
	use fcitx && emake sougou.dict
	use rime && emake sougou.dict.yaml
}

src_install() {
	use fcitx && emake DESTDIR="${ED}" install_sougou_dict
	use rime && emake DESTDIR="${ED}" install_sougou_dict_yaml
}
