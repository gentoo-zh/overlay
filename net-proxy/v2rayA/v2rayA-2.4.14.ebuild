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
# maintainer generated vendor tarballs (service and core have different go.mod)
# generated with gentoo-zh/gentoo-deps/.github/workflows/generator.yml
SRC_URI+="
	https://github.com/gentoo-zh/gentoo-deps/releases/download/v2rayA-service-${PV}/v2rayA-service-${PV}-vendor.tar.xz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/v2rayA-core-${PV}/v2rayA-core-${PV}-vendor.tar.xz
"

LICENSE="AGPL-3"
# statically linked Go deps; core is a fork of xtls/xray-core (MPL-2.0)
LICENSE+=" Apache-2.0 BSD BSD-2 GPL-3+ LGPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong"

RDEPEND="
	app-alternatives/v2ray-geoip
	app-alternatives/v2ray-geosite
"
BDEPEND="
	>=dev-lang/go-1.26:*
"

src_compile() {
	mv -v "${WORKDIR}/web" "${S}/service/server/router/web" || die

	# v2rayA 2.4.6 ships its own core (a fork of xray-core with the
	# MultiObservatory patches) instead of calling an external v2ray/xray.
	# The core is a separate Go module; build it from its own vendored deps.
	cd "${S}/core" || die
	ego build -mod=vendor -trimpath \
		-ldflags "-X main.Version=${PV}" \
		-o v2raya_core ./main

	cd "${S}/service" || die
	ego build -mod=vendor -tags "with_gvisor" \
		-ldflags "-X github.com/v2rayA/v2rayA/conf.Version=${PV}" \
		-o v2raya -trimpath
}

src_install() {
	dobin "${S}"/service/v2raya
	dobin "${S}"/core/v2raya_core

	# v2rayA looks for geodata in /usr/share/v2raya/ and symlinks it into the
	# core's runtime asset dir from there. Point it at /usr/share/v2ray/, where
	# app-alternatives/v2ray-geoip and v2ray-geosite install the actual
	# geoip.dat/geosite.dat. The core's own /usr/share/xray/ path is installed
	# by net-proxy/Xray and is unused here, so it is not linked (avoids a file
	# collision when both packages are installed).
	dosym -r /usr/share/v2ray/geoip.dat /usr/share/v2raya/geoip.dat
	dosym -r /usr/share/v2ray/geosite.dat /usr/share/v2raya/geosite.dat

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

	if has_version '<net-proxy/v2rayA-2.4.0' ; then
		elog "2.4.0 moved v2rayA's data store to SQLite. Upgrading from an"
		elog "older version runs a one-time migration that has dropped saved"
		elog "servers/subscriptions for some users (2.4.1 fixed empty"
		elog "subscriptions). Back up your config before upgrading."
		elog "net-proxy/v2rayA-2.2.7.5 is kept if you need the old version."
		elog ">> 2.4.0 起数据改用 SQLite，从旧版升级会做一次迁移，部分用户"
		elog ">> 遇到过服务器/订阅丢失（2.4.1 已修空订阅）。升级前请先备份。旧版 2.2.7.5 保留。"
	fi

	if has_version '<net-proxy/v2rayA-2.4.6' ; then
		elog "2.4.6 bundles its own v2raya_core binary (a fork of xray-core)."
		elog "net-proxy/v2ray and net-proxy/v2ray-bin are no longer required"
		elog "by v2rayA. You may remove them if not needed by other packages."
		elog ">> 2.4.6 起使用自带的 v2raya_core 内核（基于 xray-core），"
		elog ">> 不再依赖独立的 v2ray/v2ray-bin 包，可以按需清理。"
	fi
}
