# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd go-module desktop xdg git-r3

DESCRIPTION="web GUI of Project V which supports V2Ray, Xray, SS, SSR, Trojan and Pingtunnel"
HOMEPAGE="https://v2raya.org/"

EGIT_REPO_URI="https://github.com/v2rayA/v2rayA.git"
EGIT_BRANCH="main" # HEAD

LICENSE="AGPL-3"
# statically linked Go deps; core is a fork of xtls/xray-core (MPL-2.0)
LICENSE+=" Apache-2.0 BSD BSD-2 GPL-3+ LGPL-3 MIT MPL-2.0"
SLOT="0"

RDEPEND="
	app-alternatives/v2ray-geoip
	app-alternatives/v2ray-geosite
"
BDEPEND="
	>=dev-lang/go-1.26:*
	>=net-libs/nodejs-16
	sys-apps/yarn
"

src_unpack() {
	git-r3_src_unpack

	# The live ebuild has no pre-generated web/vendor bundles; fetch the web
	# deps and vendor both Go modules (service and core) from the network.
	cd "${S}/gui" || die
	yarn install --ignore-engines --check-files || die "yarn install failed"

	cd "${S}/service" || die
	ego mod vendor

	cd "${S}/core" || die
	ego mod vendor
}

src_compile() {
	cd "${S}/gui" || die
	## Fix node build error: https://github.com/webpack/webpack/issues/14532#issuecomment-947012063
	if has_version '>=dev-libs/openssl-3'; then
		export NODE_OPTIONS=--openssl-legacy-provider
	fi
	OUTPUT_DIR="${S}/service/server/router/web" yarn build || die "yarn build failed"

	# v2rayA 2.4.6+ ships its own core (a fork of xray-core with the
	# MultiObservatory patches) instead of calling an external v2ray/xray.
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

	# v2rayA looks for geodata in /usr/share/v2raya/; point it at the files
	# installed by app-alternatives/v2ray-geoip and v2ray-geosite.
	dosym -r /usr/share/v2ray/geoip.dat /usr/share/v2raya/geoip.dat
	dosym -r /usr/share/v2ray/geosite.dat /usr/share/v2raya/geosite.dat

	keepdir "/etc/v2raya"

	./service/v2raya --report config | sed '1,6d' | fold -s -w 78 | sed -E 's/^([^#].+)/# \1/'\
		>> "${S}"/install/universal/v2raya.default || die

	insinto "/etc/default"
	newins "${S}"/install/universal/v2raya.default v2raya

	systemd_dounit "${S}"/install/universal/v2raya.service
	systemd_douserunit "${S}"/install/universal/v2raya-lite.service

	newinitd "${FILESDIR}/${PN}.initd-r1" v2raya
	newinitd "${FILESDIR}/${PN}-user.initd" v2raya-user
	newconfd "${FILESDIR}/${PN}.confd" v2raya
	newconfd "${FILESDIR}/${PN}-user.confd" v2raya-user

	doicon -s 512 "${S}"/install/universal/v2raya.png
	domenu "${S}"/install/universal/v2raya.desktop
}

pkg_postinst() {
	xdg_pkg_postinst

	if has_version '<net-proxy/v2rayA-2.4.6' ; then
		elog "2.4.6 bundles its own v2raya_core binary (a fork of xray-core)."
		elog "net-proxy/v2ray and net-proxy/v2ray-bin are no longer required"
		elog "by v2rayA. You may remove them if not needed by other packages."
	fi
}
