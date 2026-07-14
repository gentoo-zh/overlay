# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module systemd

COMMIT_ID="f2ad1de5da52a1da9622285a1d61553ddaa41f21"

DESCRIPTION="A powerful, lightning fast and censorship resistant proxy"
HOMEPAGE="https://github.com/apernet/hysteria"

SRC_URI="
	https://github.com/apernet/hysteria/archive/refs/tags/app/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/hysteria/releases/download/app/v${PV}/hysteria-app-v${PV}-vendor.tar.xz
		-> ${P}-vendor.tar.xz
"

S="${WORKDIR}/${PN}-app-v${PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	>=dev-lang/go-1.25.1
"
DEPEND="
	acct-user/hysteria
	acct-group/hysteria
"
RDEPEND="${DEPEND}"

src_compile() {
	local APP_SRC_CMD_PKG="github.com/apernet/hysteria/app/v2/cmd"
	local APP_DATE
	APP_DATE=$(LC_ALL=C date -u +'%Y-%m-%dT%H:%M:%SZ' || die)
	local APP_LIB_VERSION
	APP_LIB_VERSION=$(grep github.com/apernet/quic-go core/go.mod | awk '{print $2}' | head -n 1 || die)

	CGO_ENABLED=1 ego build \
		-trimpath \
		-ldflags "-extldflags '${LDFLAGS}' \
		-X ${APP_SRC_CMD_PKG}.appVersion=${PV} \
		-X ${APP_SRC_CMD_PKG}.appDate=${APP_DATE} \
		-X ${APP_SRC_CMD_PKG}.appType=release \
		-X ${APP_SRC_CMD_PKG}.appPlatform=linux \
		-X ${APP_SRC_CMD_PKG}.appArch=$(go env GOARCH) \
		-X '${APP_SRC_CMD_PKG}.appToolchain=$(go env GOVERSION)' \
		-X ${APP_SRC_CMD_PKG}.appCommit=${COMMIT_ID} \
		-X ${APP_SRC_CMD_PKG}.libVersion=${APP_LIB_VERSION} \
		" \
		-o "${PN}" "./app"
}

src_install() {
	insinto "/etc/${PN}"
	doins "${FILESDIR}/server.yaml.example"
	doins "${FILESDIR}/client.yaml.example"

	dobin "${PN}"

	systemd_newunit "${FILESDIR}/${PN}-server_at.service" "${PN}-server@.service"
	systemd_newunit "${FILESDIR}/${PN}-client_at.service" "${PN}-client@.service"
	# compatibility services
	systemd_dounit "${FILESDIR}/${PN}-server.service"
	systemd_dounit "${FILESDIR}/${PN}-client.service"

	newinitd "${FILESDIR}/${PN}-server.initd" "${PN}-server"
	newinitd "${FILESDIR}/${PN}-client.initd" "${PN}-client"

	keepdir /etc/${PN}
}

pkg_postinst() {
	elog
	elog "Systemd services are now templates, with a configuration file"
	elog "name as a parameter. We recommend replacing: "
	elog "  hysteria-server.service -> hysteria-server@server.service"
	elog "  hysteria-client.service -> hysteria-client@client.service"
	elog
}
