# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rpm autotools

MY_PN=${PN%_*}-${PN##*_}

DESCRIPTION="Epson printer driver (L110, L210, L300, L350, L355, L550, L555)"
HOMEPAGE="http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX
	https://openprinting.github.io/foomatic/driver/epson-201207w"
SRC_URI="https://web.archive.org/web/20150803102803if_/http://download.ebz.epson.net/dsc/op/stable/SRPMS/epson-inkjet-printer-201207w-1.0.0-1lsb3.2.src.rpm"

S="${WORKDIR}/epson-inkjet-printer-filter-${PV}"
LICENSE="LGPL-2.1 EPSON"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

RDEPEND="net-print/cups"
DEPEND="${RDEPEND}"

QA_PREBUILT="
	/opt/epson-inkjet-printer-201207w/lib64/libEpson_201207w.MT.so.1.0.0
	/opt/epson-inkjet-printer-201207w/lib64/libEpson_201207w.so.1.0.0"

src_prepare() {
	eautoreconf
	chmod +x configure
	eapply_user
}

src_configure() {
	econf LDFLAGS="$LDFLAGS -Wl,--no-as-needed" --prefix=/opt/${MY_PN}
	# if you have runtime problems:
	# add "--enable-debug" and look into /tmp/epson-inkjet-printer-filter.txt
}

src_install() {
	insinto /opt/${MY_PN}/cups/lib/filter
	doins src/epson_inkjet_printer_filter
	chmod 755 "${D}/opt/${MY_PN}/cups/lib/filter/epson_inkjet_printer_filter"

	use amd64 && X86LIB=64

	insinto /opt/${MY_PN}
	for folder in lib"${X86LIB}" resource watermark; do
		doins -r ../${MY_PN}-${PV}/$folder
	done

	insinto /usr/share/cups/model/${MY_PN}
	doins ../${MY_PN}-${PV}/ppds/*

	dodoc "AUTHORS" "COPYING" "COPYING.LIB" "COPYING.EPSON"
	dodoc ../${MY_PN}-${PV}/{Manual.txt,README}
}
