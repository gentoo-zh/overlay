# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Converts iOS 11 HEIC images to practical formats - Static binary"
HOMEPAGE="https://github.com/monostream/tifig"
SRC_URI="https://github.com/monostream/${PN%-bin}/releases/download/${PV}/${PN%-bin}-static-${PV}.tar.gz"

S="${WORKDIR}"
LICENSE="Apache-2.0 LGPL-2.1+ MIT Nokia-HEIF-1.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

src_install(){
	dobin ${PN%-bin}
	fperms 0755 "/usr/bin/${PN%-bin}"
}
