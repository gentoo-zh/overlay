# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

MY_PN="SarasaTermSCNerd"
DESCRIPTION="Sarasa Mono SC font patched with Nerd fonts"
HOMEPAGE="https://github.com/laishulu/Sarasa-Term-SC-Nerd"

SRC_URI="https://github.com/laishulu/Sarasa-Term-SC-Nerd/releases/download/v${PV}/${MY_PN}.ttf.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}"
LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
FONT_SUFFIX="ttf"
