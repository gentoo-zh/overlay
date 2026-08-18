# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-env go-module systemd shell-completion

_PV="${PV/_/-}"
_PV="${_PV/alpha/alpha.}"
_PV="${_PV/beta/beta.}"
_PV="${_PV/rc/rc.}"

VENDOR_PREFIX="https://github.com/gentoo-zh-drafts/sing-box/releases/download/v${_PV}"

DESCRIPTION="The universal proxy platform"
HOMEPAGE="https://sing-box.sagernet.org/ https://github.com/SagerNet/sing-box"
SRC_URI="
	https://github.com/SagerNet/sing-box/archive/refs/tags/v${_PV}.tar.gz -> ${P}.tar.gz
	${VENDOR_PREFIX}/sing-box-${_PV}-vendor-lite.tar.xz
	naive? (
		amd64? ( ${VENDOR_PREFIX}/sing-box-${_PV}-vendor-libcronet-so-amd64.tar.xz )
		arm64? ( ${VENDOR_PREFIX}/sing-box-${_PV}-vendor-libcronet-so-arm64.tar.xz )
		riscv? ( ${VENDOR_PREFIX}/sing-box-${_PV}-vendor-libcronet-so-riscv64.tar.xz )
	)
"

S="${WORKDIR}/${PN}-${_PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"

# Follow: https://sing-box.sagernet.org/installation/build-from-source/#build-tags
# In upstream versions, `naive` is enabled by default, but in Gentoo's downstream versions, it is disabled by default.
IUSE="
	+quic grpc +dhcp +wireguard +utls +acme +clash-api v2ray-api
	+gvisor tor +tailscale +ccm +ocm naive +cloudflared
"

RDEPEND="
	acct-group/${PN}
	acct-user/${PN}
"

src_compile() {
	local mytags
	use quic && mytags+="with_quic,"
	use grpc && mytags+="with_grpc,"
	use dhcp && mytags+="with_dhcp,"
	use wireguard && mytags+="with_wireguard,"
	use utls && mytags+="with_utls,"
	use acme && mytags+="with_acme,"
	use clash-api && mytags+="with_clash_api,"
	use v2ray-api && mytags+="with_v2ray_api,"
	use gvisor && mytags+="with_gvisor,"
	use tor && mytags+="with_embedded_tor,"
	use tailscale && mytags+="with_tailscale,"
	use ccm && mytags+="with_ccm,"
	use ocm && mytags+="with_ocm,"
	use naive && mytags+="with_purego,with_naive_outbound,"
	use cloudflared && mytags+="with_cloudflared,"

	ego build -tags "${mytags%,}" \
		-ldflags "-X 'github.com/sagernet/sing-box/constant.Version=${PV}'" \
		./cmd/sing-box

	mkdir completions
	./sing-box completion bash > completions/sing-box
	./sing-box completion fish > completions/sing-box.fish
	./sing-box completion zsh > completions/_sing-box
}

src_install() {
	if ! use naive; then
		dobin sing-box
	else
		insinto /usr/lib/sing-box
		doins sing-box "vendor/github.com/sagernet/cronet-go/lib/linux_$(go-env_goarch)/libcronet.so"
		dosym ../lib/sing-box/sing-box /usr/bin/sing-box
		fperms +x /usr/bin/sing-box /usr/lib/sing-box/sing-box
	fi

	insinto /etc/sing-box
	newins release/config/config.json config.json.example

	newinitd release/config/sing-box.initd sing-box
	systemd_dounit release/config/sing-box{,@}.service

	insinto /usr/share/dbus-1/system.d
	newins release/config/sing-box-split-dns.xml sing-box-dns.conf

	insinto /usr/share/polkit-1/rules.d
	doins release/config/sing-box.rules

	dobashcomp completions/sing-box
	dofishcomp completions/sing-box.fish
	dozshcomp completions/_sing-box
}
