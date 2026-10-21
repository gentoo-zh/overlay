# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion go-module systemd

DESCRIPTION="A swiss army knife for Debian repository management"
HOMEPAGE="https://github.com/aptly-dev/aptly"
SRC_URI="https://github.com/aptly-dev/aptly/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/gentoo-zh-drafts/aptly/releases/download/v${PV}/${P}-vendor.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test" # fails

RDEPEND="
	acct-group/aptly
	acct-user/aptly
"
BDEPEND=">=dev-lang/go-1.25.0"

src_prepare() {
	default
	printf '%s' "${PV}" > VERSION || die
}

src_compile() {
	ego build -mod=vendor -o cmd/aptly -ldflags "-X main.Version=${PV}"
}

src_test() {
	ego test -work ./...
}

src_install() {
	einstalldocs
	dobin cmd/aptly
	doman man/aptly.1
	dobashcomp completion.d/aptly
	dozshcomp completion.d/_aptly
	systemd_dounit "${FILESDIR}"/aptly-api.service
	systemd_dounit "${FILESDIR}"/aptly.service
	newinitd "${FILESDIR}"/aptly.initd aptly
	newconfd "${FILESDIR}"/aptly.confd aptly
	newinitd "${FILESDIR}"/aptly-api.initd aptly-api
	newconfd "${FILESDIR}"/aptly-api.confd aptly-api

	diropts -o aptly -g aptly -m 0700
	keepdir /etc/aptly
	insopts -o aptly -g aptly -m 0644
	insinto /etc/aptly
	doins "${FILESDIR}"/aptly.conf
}
