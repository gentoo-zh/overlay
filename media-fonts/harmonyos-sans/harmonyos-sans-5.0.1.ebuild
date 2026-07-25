# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="HarmonyOS Sans: Huawei's sans-serif typeface with CJK support"
HOMEPAGE="https://developer.huawei.com/consumer/cn/design/resource/"
SRC_URI="https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyManage/011/111/111/0000000000011111111.20260611171743.77886644144213121813005934094365:50001231000000:2800:0CCF575ADA0FCAD85EE25909C15C402A40FA94ABCCFEFC5BD37061A6B94239FF.zip -> ${P}.zip"
S="${WORKDIR}/HarmonyOS Sans"

LICENSE="HarmonyOS-Sans"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"

FONT_SUFFIX="ttf"
RESTRICT="mirror"

BDEPEND="app-arch/unzip"
