# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="juicity is a quic-based proxy protocol"
HOMEPAGE="https://github.com/juicity/juicity"
SRC_URI="https://github.com/juicity/juicity/releases/download/v${PV}/juicity-full-src.zip -> ${P}.zip"

S="$WORKDIR"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE="+server client"

src_compile(){
	for i in server client ;do
		if use $i; then
			CGO_ENABLED=0 ego build \
				-trimpath \
				-ldflags "-X github.com/juicity/juicity/config.Version=${PV}" \
				-o "juicity-${i}" "./cmd/${i}"
		fi
	done
}

src_install(){
	keepdir "/etc/${PN}"
	insinto "/etc/${PN}"
	for i in server client ;do
		if use $i; then
			dobin "juicity-$i"
			systemd_dounit "install/juicity-$i.service"
			doins "install/example-$i.json"
		fi
	done
}
