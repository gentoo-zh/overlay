EAPI=8
inherit desktop unpacker

DESCRIPTION="A violent, sexy, multiplayer first person shooter based on the ioquake3 engine"
HOMEPAGE="https://openarena.ws https://en.wikipedia.org/wiki/OpenArena"
SRC_URI="
	https://downloads.sourceforge.net/oarena/openarena-0.8.8.zip
	https://upload.wikimedia.org/wikipedia/commons/2/2c/Openarena.png
	https://upload.wikimedia.org/wikipedia/commons/7/7b/Openarena-server.png
"
inherit git-r3
EGIT_REPO_URI="https://github.com/OpenArena/engine"

LICENSE="GPL-3"

SLOT="0"

BDEPEND="app-arch/unzip"

DEPEND="
	media-libs/libvorbis
	net-misc/curl
	media-libs/openal
	media-libs/libxmp
	media-libs/libsdl
"

RDEPEND="!games-fps/openarena-bin"

src_unpack() {
	git-r3_src_unpack
	unpacker_src_unpack
}

src_compile() {
	if use amd64; then
		COMPILE_ARCH=x86_64
		ARCH=x86_64
	fi
	emake
}

src_install() {
	insinto /opt/openarena
	doins "${FILESDIR}/openarena-runner.sh"
	doins -r build/*/*
	fperms +x /opt/openarena/openarena-runner.sh

	insinto /opt/openarena/baseoa
	doins "${S}"/baseoa/*.pk3

	insinto /opt/openarena/missionpack/
	doins "${S}"/missionpack/*.pk3

	domenu "${FILESDIR}/openarena.desktop"
	domenu "${FILESDIR}/openarena-server.desktop"
	doicon "${DISTDIR}/openarena.png"
	doicon "${DISTDIR}/openarena-server.png"

	dosym ../../opt/openarena/openarena-runner.sh /usr/bin/openarena
	dosym ../../opt/openarena/openarena-runner.sh /usr/bin/openarena-server
}
