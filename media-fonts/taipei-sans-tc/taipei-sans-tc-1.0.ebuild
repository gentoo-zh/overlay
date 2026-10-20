# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit font

MY_PN="TaipeiSansTCBeta"
P_REGULAR="${MY_PN}-Regular"
P_LIGHT="${MY_PN}-Light"
P_BOLD="${MY_PN}-Bold"

DESCRIPTION="JT Foundry - Taipei Sans TC Beta font"
HOMEPAGE="https://sites.google.com/view/jtfoundry/"
SRC_URI="https://drive.google.com/uc?export=download&id=1eGAsTN1HBpJAkeVM57_C7ccp7hbgSz3_ -> ${P_REGULAR}.ttf"
SRC_URI+=" https://drive.google.com/uc?export=download&id=1QdaqR8Setf4HEulrIW79UEV_Lg_fuoWz -> ${P_LIGHT}.ttf"
SRC_URI+=" https://drive.google.com/uc?export=download&id=1Om8izPz02Msc15onhS_ki1lrlAIf05Pd -> ${P_BOLD}.ttf"

S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ppc ~ppc64 ~s390 ~sparc ~x86"

FONT_S="${S}"
FONT_SUFFIX="ttf"

src_unpack() {
	for p in "${P_REGULAR}" "${P_BOLD}" "${P_LIGHT}"; do
		cp "${DISTDIR}/${p}.${FONT_SUFFIX}" "${FONT_S}" || die
	done
}
