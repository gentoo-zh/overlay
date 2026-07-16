# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

# I don't know why Baidu changed the URL structure, but they did,
# so I add this to match the new 4-digit directory version.

DESCRIPTION="Baidu Net Disk is a cloud storage client (Linux Version)"
HOMEPAGE="https://pan.baidu.com/"
SRC_URI="https://issuecdn.baidupcs.com/issue/netdisk/LinuxGuanjia/${PV}/${PN}_${PV}_amd64.deb"

S="${WORKDIR}"
LICENSE="BaiduNetDisk"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip mirror"

RDEPEND="
	app-crypt/p11-kit
	dev-libs/nss
	media-libs/alsa-lib
	x11-libs/gtk+:3[cups,X,wayland]
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	dev-cpp/gtkmm:2.4
"

QA_PREBUILT="*"

src_install() {
	insinto /opt
	doins -r opt/"${PN}"
	find "${D}" -type d -name "node_gyp_bins" -exec rm -rf {} + 2>/dev/null
	find "${D}" -type d -empty -delete 2>/dev/null

	fperms +x /opt/"${PN}"/"${PN}"
	fperms +x /opt/"${PN}"/baidunetdiskhost
	fperms +x /opt/"${PN}"/netdisk_service
	fperms +x /opt/"${PN}"/chrome-sandbox
	fperms +x /opt/"${PN}"/chrome_crashpad_handler

	dosym -r /opt/{"${PN}"/"${PN}",bin/"${PN}"}

	gzip -d usr/share/doc/"${PN}"/*.gz || die
	dodoc usr/share/doc/"${PN}"/*

	domenu usr/share/applications/"${PN}".desktop
	doicon -s scalable usr/share/icons/hicolor/scalable/apps/"${PN}".svg
}
