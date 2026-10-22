# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg
DESCRIPTION="Document Viewer for CAJ, KDH, NH, TEB and PDF format"

HOMEPAGE="https://cajviewer.cnki.net"
# download.cnki.net may only serve this file to Hong Kong and mainland China;
# elsewhere it returns a certificate for another host, so the fetch fails.
SRC_URI="https://download.cnki.net/cajPackage/CAJLinuxPackage/${PN}_${PV}_amd64.deb"
S="${WORKDIR}"

LICENSE="CAJVIEWER-EULA"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-crypt/p11-kit
	dev-db/freetds
	dev-libs/expat
	dev-libs/gmp
	dev-libs/libgpg-error
	dev-libs/libxml2-compat:2
	dev-libs/libxslt
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd
	media-libs/tiff-compat:4
	virtual/libudev
	virtual/zlib
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
"
DEPEND="${RDEPEND}"

MY_PREFIX="/opt/${PN}"

QA_PREBUILT="
	/opt/cajviewer/lib/*.so*
	/opt/cajviewer/plugins/*/*.so
	/opt/cajviewer/libexec/QtWebEngineProcess
"

src_install(){
	# fix preserved libs warning due to dev-qt/qtvirtualkeyboard
	rm -f "${S}"/opt/cajviewer/plugins/platforminputcontexts/libqtvirtualkeyboardplugin.so || die
	# needs libQt5Pdf.so.5, which the package does not bundle
	rm -f "${S}"/opt/cajviewer/plugins/imageformats/libqpdf.so || die

	insinto "/opt"
	doins -r "./${MY_PREFIX}"

	fperms +x "${MY_PREFIX}/bin/start.sh"
	fperms +x "${MY_PREFIX}/bin/CAJViewer"
	fperms +x "${MY_PREFIX}/libexec/QtWebEngineProcess"

	domenu "./usr/share/applications/cajviewer.desktop"

	for size in 16 22 24 32 48 64 128; do
		doicon -s ${size} -c mimetypes ./usr/share/icons/hicolor/${size}x${size}/mimetypes/application-teb.png
		doicon -s ${size} -c mimetypes ./usr/share/icons/hicolor/${size}x${size}/mimetypes/application-pdf.png
		doicon -s ${size} -c mimetypes ./usr/share/icons/hicolor/${size}x${size}/mimetypes/application-nh.png
		doicon -s ${size} -c mimetypes ./usr/share/icons/hicolor/${size}x${size}/mimetypes/application-kdh.png
		doicon -s ${size} -c mimetypes ./usr/share/icons/hicolor/${size}x${size}/mimetypes/application-epub.png
		doicon -s ${size} -c mimetypes ./usr/share/icons/hicolor/${size}x${size}/mimetypes/application-caj.png
	done

	insinto "/usr/share/mime/packages/"
	doins "./usr/share/mime/packages/cnki-caj.xml"
}
