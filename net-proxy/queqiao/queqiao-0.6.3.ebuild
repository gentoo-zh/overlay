# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Self-hosted WAN optimization proxy for difficult long-haul links"
HOMEPAGE="https://github.com/bojieli/queqiao"
SRC_URI="
	https://github.com/bojieli/queqiao/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/irort/gentoo-deps/releases/download/${P}/${P}-vendor.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	acct-group/${PN}
	acct-user/${PN}
"
BDEPEND="${RDEPEND}
	>=dev-lang/go-1.25.13
"

src_prepare() {
	rm -r mobile || die
	sed -i 's|/usr/local/bin|/usr/bin|' deploy/queqiaod.service || die
	default
}

src_compile() {
	ego build -o queqiaod -trimpath \
		-ldflags "-X main.version=${PV}" \
		./cmd/queqiaod
}

src_install() {
	dobin queqiaod

	keepdir /var/log/queqiao
	fowners queqiao:queqiao /var/log/queqiao
	fperms 750 /var/log/queqiao
	insinto /etc/queqiao
	doins "${FILESDIR}/queqiaod.env"

	systemd_dounit deploy/queqiaod.service
}
