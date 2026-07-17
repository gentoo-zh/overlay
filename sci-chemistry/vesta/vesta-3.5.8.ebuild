# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg

DESCRIPTION="Visualization for Electronic and STructural Analysis"
HOMEPAGE="https://jp-minerals.org/vesta/"
SRC_URI="https://jp-minerals.org/vesta/archives/${PV}/VESTA-gtk3.tar.bz2 -> ${PN}-${PV}.tar.bz2"

S="${WORKDIR}/VESTA-gtk3"

LICENSE="VESTA"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror strip"

RDEPEND="
	x11-libs/gtk+:3[wayland]
	virtual/glu
	dev-util/desktop-file-utils
	x11-libs/libXtst
	virtual/jdk
	${DEPEND}"

QA_PREBUILT="*"

src_install() {
	insinto /opt/VESTA
	doins -r *
	fperms +x /opt/VESTA/VESTA
	fperms +x /opt/VESTA/VESTA-gui

	domenu "${FILESDIR}/VESTA.desktop"

	dosym ../VESTA/VESTA /opt/bin/VESTA
	dosym ../VESTA/VESTA /opt/bin/vesta
}

pkg_postinst() {
	xdg_desktop_database_update

	elog "If you meet any abnormal behavior while using VESTA after upgrade or downgrade,"
	elog "try remove ~/.VESTA and restart VESTA. Note that this will make you lost"
	elog "all your saved configs."
}

pkg_postrm() {
	xdg_desktop_database_update
}
