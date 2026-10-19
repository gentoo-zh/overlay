# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="A Functional Language with Effect Types and Handlers"
HOMEPAGE="https://github.com/koka-lang/koka"
SRC_URI="
	amd64? ( https://github.com/koka-lang/koka/releases/download/v${PV}/koka-v${PV}-linux-x64.tar.gz )
	arm64? ( https://github.com/koka-lang/koka/releases/download/v${PV}/koka-v${PV}-linux-arm64.tar.gz )
"

S="${WORKDIR}"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RESTRICT="strip"

src_install() {
	dobin "${S}/bin/koka"
	insinto /usr/lib/koka/v${PV}
	doins -r "${S}/lib/koka/v${PV}"/*
	insinto /usr/share/koka/v${PV}
	doins -r "${S}/share/koka/v${PV}"/*
}
