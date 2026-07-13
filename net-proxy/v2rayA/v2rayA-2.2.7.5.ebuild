# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
NONFATAL_VERIFY=1
inherit systemd go-module desktop xdg

DESCRIPTION="web GUI of Project V which supports V2Ray, Xray, SS, SSR, Trojan and Pingtunnel"
HOMEPAGE="https://v2raya.org/"

SRC_URI="
	https://github.com/v2rayA/v2rayA/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/v2rayA/v2rayA/releases/download/v${PV}/web.tar.gz -> ${P}-web.tar.gz
"
# maintainer generated deps pack
# generated with gentoo-zh/gentoo-deps/.github/workflows/generator.yml
SRC_URI+="
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-deps.tar.xz
"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong"
IUSE="xray"

RDEPEND="
	|| (
		>=net-proxy/v2ray-5
		>=net-proxy/v2ray-bin-5
	)
	xray? ( net-proxy/Xray )
"
BDEPEND="
	>=dev-lang/go-1.21:*
"

src_compile() {
	mv -v "${WORKDIR}/web" "${S}/service/server/router/web" || die

	cd "${S}/service" || die
	ego build -tags "with_gvisor" \
		-ldflags "-X github.com/v2rayA/v2rayA/conf.Version=${PV}" \
		-o v2raya -trimpath
}

src_install() {
	dobin "${S}"/service/v2raya
	# directory for runtime use
	keepdir "/etc/v2raya"

	./service/v2raya --report config | sed '1,6d' | fold -s -w 78 | sed -E 's/^([^#].+)/# \1/'\
		>> "${S}"/install/universal/v2raya.default || die

	# config /etc/default/v2raya
	insinto "/etc/default"
	newins "${S}"/install/universal/v2raya.default v2raya

	systemd_dounit "${S}"/install/universal/v2raya.service
	systemd_douserunit "${S}"/install/universal/v2raya-lite.service

	#thanks to @Universebenzene
	newinitd "${FILESDIR}/${PN}.initd-r1" v2raya
	newinitd "${FILESDIR}/${PN}-user.initd" v2raya-user
	newconfd "${FILESDIR}/${PN}.confd" v2raya
	newconfd "${FILESDIR}/${PN}-user.confd" v2raya-user

	doicon -s 512 "${S}"/install/universal/v2raya.png
	domenu "${S}"/install/universal/v2raya.desktop
}

pkg_postinst() {
	xdg_pkg_postinst

	if has_version '<net-proxy/v2rayA-2.0.0' ; then
		elog "Starting from net-proxy/v2rayA-2.0.0"
		elog "Support for v2ray-4 has been dropped"
		elog "A config migration may be required"
	fi
}
