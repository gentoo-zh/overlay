# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature unpacker xdg

DESCRIPTION="The official unity tool for manager Unity Engines and projects"
HOMEPAGE="https://docs.unity.com/en-us/hub"
SRC_URI="https://hub.unity3d.com/linux/repos/deb/pool/main/u/unity/unityhub_amd64/UnityHubSetup-${PV}-amd64.deb -> ${PN}-amd64-${PV}.deb"
S=${WORKDIR}

LICENSE="unity-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libnotify"
RESTRICT="bindist mirror strip"

QA_PREBUILT="opt/unityhub/*"

RDEPEND="
	libnotify? (
		x11-libs/libnotify
	)
	app-arch/unzip
	app-arch/zip
	app-crypt/libsecret
	dev-libs/wayland
	|| (
		dev-libs/openssl-compat:3
		dev-libs/openssl:0/3
	)
	media-libs/fontconfig
	media-libs/libglvnd
	media-libs/mesa
	media-libs/vulkan-loader
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-misc/xdg-utils
"

src_unpack(){
	unpack_deb ${PN}-amd64-${PV}.deb
}
src_install(){
	dodir /opt
	cp -a usr/lib/unityhub "${ED}/opt/" || die
	dosym -r /opt/unityhub/unityhub /usr/bin/unityhub
	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor
	domenu usr/share/applications/${PN}.desktop
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature_header "Older Unity Editor releases installed through the Hub may need:"
	optfeature "Editors before Unity's libxml2 fix (6000.0.76f1, 6000.3.13f1, 6000.4.1f1)" \
		dev-libs/libxml2-compat:2
}
