# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module fcaps

DESCRIPTION="An open source visual routing tool that pursues light weight"
HOMEPAGE="https://www.nxtrace.org/ https://github.com/nxtrace/NTrace-core"
SRC_URI="
	https://github.com/nxtrace/NTrace-core/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/NTrace-core/releases/download/v${PV}/NTrace-core-${PV}-vendor.tar.xz
		-> ${P}-vendor.tar.xz
"

S="${WORKDIR}/NTrace-core-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"

IUSE="+full tiny ntr"
REQUIRED_USE="|| ( full tiny ntr )"

BDEPEND=">=dev-lang/go-1.27.3"

src_compile() {
	local ldflags=(
		-ldflags " \
			-X github.com/nxtrace/NTrace-core/config.Version=v${PV} \
			-X github.com/nxtrace/NTrace-core/config.BuildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
			-X github.com/nxtrace/NTrace-core/config.CommitID=unknown
		"
	)

	use full && ego build -o nexttrace "${ldflags[@]}" .
	use tiny && ego build -tags flavor_tiny -o nexttrace-tiny "${ldflags[@]}" .
	use ntr && ego build -tags flavor_ntr -o ntr "${ldflags[@]}" .
}

src_install() {
	FILECAPS=( "cap_net_admin,cap_net_raw=eip" )

	if use full; then
		dobin nexttrace
		FILECAPS+=( "usr/bin/nexttrace" )
	fi
	if use tiny; then
		dobin nexttrace-tiny
		FILECAPS+=( "usr/bin/nexttrace-tiny" )
	fi
	if use ntr; then
		dobin ntr
		FILECAPS+=( "usr/bin/ntr" )
	fi

	if ! use full && use tiny; then
		dosym nexttrace-tiny /usr/bin/nexttrace
	fi
}
