# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg desktop unpacker

DESCRIPTION="The official unity tool for manager Unity Engines and projects"
HOMEPAGE="https://docs.unity.com/en-us/hub"
SRC_URI="https://hub.unity3d.com/linux/repos/deb/pool/main/u/unity/unityhub_amd64/UnityHubSetup-${PV}-amd64.deb -> ${PN}-amd64-${PV}.deb"
S=${WORKDIR}

LICENSE="unity-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+appindicator legacy"
RESTRICT="mirror strip"

DEPEND="
	appindicator? (
		dev-libs/libdbusmenu
		legacy? (
			dev-libs/libayatana-appindicator
			x11-misc/appmenu-gtk-module[gtk2]
		)
	)
	app-arch/cpio
	dev-libs/nss
	dev-util/lttng-ust:0/2.12
	x11-libs/gtk+
	app-crypt/libsecret
	dev-libs/openssl-compat
	media-libs/alsa-lib
"
RDEPEND="${DEPEND}"

src_unpack(){
	unpack_deb ${PN}-amd64-${PV}.deb
}
src_install(){
	# Drop bundled arm64 optional dependencies from the amd64 package.
	rm -r \
		"${S}"/opt/unityhub/resources/app.asar.unpacked/node_modules/@napi-rs/canvas-linux-arm64-gnu \
		"${S}"/opt/unityhub/resources/app.asar.unpacked/node_modules/@napi-rs/keyring-linux-arm64-gnu \
		"${S}"/opt/unityhub/resources/app.asar.unpacked/node_modules/@vscode/ripgrep-linux-arm64 \
		"${S}"/opt/unityhub/resources/app.asar.unpacked/node_modules/@unity/hub-fs-linux-arm64-gnu \
		"${S}"/opt/unityhub/resources/app.asar.unpacked/node_modules/@unity/hub-proxy-linux-arm64-gnu \
		|| die

	insinto "/opt"
	doins -r "${S}/opt/unityhub"
	dosym -r /opt/unityhub/unityhub /usr/bin/unityhub
	for si in 16 32 48 64 128 256 512; do
		doicon -s ${si} usr/share/icons/hicolor/${si}x${si}/apps/${PN}.png
	done
	domenu "${WORKDIR}/usr/share/applications/unityhub.desktop"
	fperms 0755 -R "/opt/unityhub"
}
