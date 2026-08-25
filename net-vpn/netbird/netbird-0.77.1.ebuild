# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="An Open Source Zero Trust Networking platform"
HOMEPAGE="https://netbird.io/ https://github.com/netbirdio/netbird/"
SRC_URI="https://github.com/netbirdio/netbird/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/gentoo-zh-drafts/netbird/releases/download/v${PV}/${P}-vendor.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~riscv ~x86"
RESTRICT="test" # fails with network-sandbox
BDEPEND=">=dev-lang/go-1.25.5"

PATCHES="${FILESDIR}/${P}-systemd-service-sbin.patch"

src_compile() {
	mkdir build || die
	ego build -o build -ldflags="
		-X 'github.com/netbirdio/netbird/version.version=${PV}'
		-extldflags '${LDFLAGS}'
		" ./client
}

src_install() {
	newsbin build/client netbird
	fperms 0700 /usr/sbin/netbird

	systemd_dounit "release_files/systemd/netbird@.service"
	newinitd "${FILESDIR}"/netbird.initd netbird

	einstalldocs
}
