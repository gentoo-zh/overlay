# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A Layer Two Peer-to-Peer VPN"

inherit systemd cmake git-r3

HOMEPAGE="https://github.com/ntop/n2n"
LICENSE="GPL-3"
SLOT="0"
IUSE="
	+openssl
	caps
	pcap
	zstd
	upnp
"

EGIT_REPO_URI="https://github.com/ntop/n2n.git"

DEPEND="
	acct-user/n2n
	acct-group/n2n
	openssl? ( dev-libs/openssl )
	caps? ( sys-libs/libcap )
	pcap? ( net-libs/libpcap )
	zstd? ( app-arch/zstd )
	upnp? ( net-libs/miniupnpc net-libs/libnatpmp )
"
RDEPEND="${DEPEND}"

src_configure() {
	mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DN2N_OPTION_USE_OPENSSL="$(usex openssl ON OFF)"
		-DN2N_OPTION_USE_OPENSSL="$(usex openssl ON OFF)"
		-DN2N_OPTION_USE_CAPLIB="$(usex caps ON OFF)"
		-DN2N_OPTION_USE_PCAPLIB="$(usex pcap ON OFF)"
		-DN2N_OPTION_USE_ZSTD="$(usex zstd ON OFF)"
		-DN2N_OPTION_USE_PORTMAPPING="$(usex upnp ON OFF)"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	rm -r "${D:?}/usr/share" || die
	doman "${S}/edge.8"
	doman "${S}/n2n.7"
	doman "${S}/supernode.1"
	keepdir /var/log/n2n
	systemd_newunit "${S}/packages/etc/systemd/system/edge@.service.in" n2n-edge@.service
	systemd_newunit "${S}/packages/etc/systemd/system/supernode.service.in" n2n-supernode.service
	insinto /etc/n2n
	newins "${S}/packages/etc/n2n/edge.conf.sample" edge-example.conf
	doins "${S}/packages/etc/n2n/supernode.conf.sample"
}
