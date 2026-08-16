# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module systemd

DESCRIPTION="Another Clash Kernel, formerly Clash.Meta"
HOMEPAGE="
	https://wiki.metacubex.one/
	https://github.com/MetaCubeX/mihomo/
"
SRC_URI="
	https://github.com/MetaCubeX/mihomo/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/mihomo/releases/download/v${PV}/${P}-vendor.tar.xz
"

BDEPEND=">=dev-lang/go-1.20.4"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong"
IUSE="+gvisor"

src_compile() {
	local BUILDTIME=$(LC_ALL=C date -u || die)
	local MY_TAGS
	use gvisor && MY_TAGS="with_gvisor"
	ego build -tags "${MY_TAGS}" -trimpath -ldflags "
		-linkmode external -extldflags '${LDFLAGS}' \
		-X github.com/metacubex/mihomo/constant.Version=${PV} \
		-X 'github.com/metacubex/mihomo/constant.BuildTime=${BUILDTIME}'"
}

src_install() {
	dobin mihomo
	dosym mihomo /usr/bin/clash-meta
	systemd_dounit .github/release/mihomo.service
	systemd_dounit .github/release/mihomo@.service
	newinitd "${FILESDIR}"/mihomo.initd mihomo

	keepdir /etc/mihomo
	insinto /etc/mihomo
	newins .github/release/config.yaml config.yaml.example
	einstalldocs
}
