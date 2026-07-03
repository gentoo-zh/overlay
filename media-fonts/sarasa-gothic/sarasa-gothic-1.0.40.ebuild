# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font unpacker

MY_PN="Sarasa"
DESCRIPTION="A CJK programming font based on Iosevka and Source Han Sans. (TTC)"
HOMEPAGE="https://github.com/be5invis/Sarasa-Gothic"
SRC_URI="https://github.com/be5invis/Sarasa-Gothic/releases/download/v${PV}/${MY_PN}-TTC-${PV}.zip"
S="${WORKDIR}"
LICENSE="OFL-1.1"
SLOT="0"

KEYWORDS="~amd64 ~x86"
BDEPEND="
	app-arch/unzip
"

FONT_S="${S}"
FONT_SUFFIX="ttc"
