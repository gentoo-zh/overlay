# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Disassembler library for x86 (32-bit shared library)"
HOMEPAGE="https://www.deepin.org"

COMMON_URI="https://community-packages.deepin.com/deepin/pool/non-free/u"
SRC_URI="${COMMON_URI}/udis86/udis86_${PV}-4_i386.deb"

S=${WORKDIR}
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

QA_PREBUILT="usr/bin/udcli usr/include/udis86* usr/include/libudis86 usr/include/libudis86/* /usr/lib/libudis86*"
QA_FLAGS_IGNORED="usr/bin/udcli usr/include/udis86* usr/include/libudis86 usr/include/libudis86/* /usr/lib/libudis86*"

src_install() {
	insinto /usr
	doins -r usr/bin usr/include usr/lib

	fperms 0755 -R /usr/bin/
	find "${ED}" -name '*.la' -delete || die
}
