# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module systemd

DESCRIPTION="A platform for building proxies to bypass network restrictions."
HOMEPAGE="https://www.v2fly.org/"
SRC_URI="
	https://github.com/v2fly/v2ray-core/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/v2ray-core/releases/download/v${PV}/v2ray-core-${PV}-vendor.tar.xz
"
S="${WORKDIR}/${PN}-core-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~riscv ~x86"

DEPEND="!net-proxy/v2ray-bin
	app-alternatives/v2ray-geoip
	app-alternatives/v2ray-geosite
"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.25.5"

src_prepare() {
	sed -i 's|/usr/local/bin|/usr/bin|;s|/usr/local/etc|/etc|' release/config/systemd/system/*.service || die
	sed -i '/^User=/s/nobody/v2ray/;/^User=/aDynamicUser=true' release/config/systemd/system/*.service || die
	default
}

src_compile() {
	ego build -o v2ray ./main
}

src_install() {
	dobin v2ray

	insinto /etc/v2ray
	newins release/config/config.json config.json.example

	newinitd "${FILESDIR}/v2ray.initd-r1" v2ray
	systemd_dounit release/config/systemd/system/v2ray{,@}.service
}
