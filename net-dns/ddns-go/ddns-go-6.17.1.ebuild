# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Automatically obtain your public IP address and set to your domain name service"
HOMEPAGE="https://github.com/jeessy2/ddns-go"
SRC_URI="
	https://github.com/jeessy2/ddns-go/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-vendor.tar.xz
"

LICENSE="MIT BSD"
SLOT="0"
KEYWORDS="~amd64 ~riscv"

BDEPEND=">=dev-lang/go-1.25.0"

PATCHES=(
	"${FILESDIR}/${PN}-6.13.2-remove_update_support.patch"
	"${FILESDIR}/${PN}-6.13.2-remove_service_management_support.patch"
	"${FILESDIR}/${PN}-6.17.1-build_deps_tidy.patch"
)

src_compile() {
	ego build -o "${PN}" \
		-ldflags="-linkmode external \
			-X 'main.version=${PV} (Gentoo)' \
			-X 'main.buildTime=$(date -u +"%Y-%m-%dT%H:%M:%SZ")'" \
		.
}

src_install() {
	dobin "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
	systemd_newunit "${FILESDIR}/${PN}_at.service" "${PN}@.service"
	systemd_dounit "${FILESDIR}/${PN}-web.service"
	keepdir "/etc/${PN}"
}
