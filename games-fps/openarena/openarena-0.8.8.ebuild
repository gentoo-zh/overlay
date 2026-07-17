EAPI=8
inherit desktop unpacker

DESCRIPTION="A violent, sexy, multiplayer first person shooter based on the ioquake3 engine"
HOMEPAGE="https://openarena.ws https://en.wikipedia.org/wiki/OpenArena"
SRC_URI="
	https://downloads.sourceforge.net/oarena/${P}.zip
	https://github.com/OpenArena/legacy/archive/3db79b091ce1d950d9cdcac0445a2134f49a6fc7.tar.gz -> ${P}-engine.tar.gz
	https://upload.wikimedia.org/wikipedia/commons/2/2c/Openarena.png
	https://upload.wikimedia.org/wikipedia/commons/7/7b/Openarena-server.png
"

LICENSE="GPL-2+"

SLOT="0"

KEYWORDS="~amd64 ~x86"

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
	unpacker_src_unpack
	mv legacy-3db79b091ce1d950d9cdcac0445a2134f49a6fc7/* "${S}" || die
}

src_compile() {
	if use amd64; then
		COMPILE_ARCH=x86_64
		ARCH=x86_64
	fi
	cd "${S}/engine/openarena-engine-source-${PV}"
	emake
}

src_install() {
	insinto /opt/openarena/
	doins "${FILESDIR}/openarena-runner.sh"
	fperms +x /opt/openarena/openarena-runner.sh
	doins -r "${S}/engine/openarena-engine-source-${PV}/build"/*/*
	fperms +x /opt/openarena/oa_ded.x86_64 /opt/openarena/openarena.x86_64

	insinto /opt/openarena/baseoa/
	doins "${S}"/baseoa/*.pk3

	insinto /opt/openarena/missionpack/
	doins "${S}"/missionpack/*.pk3

	domenu "${FILESDIR}/openarena.desktop"
	domenu "${FILESDIR}/openarena-server.desktop"
	doicon "${DISTDIR}/Openarena.png"
	doicon "${DISTDIR}/Openarena-server.png"

	dosym ../../opt/openarena/openarena-runner.sh /usr/bin/openarena
	dosym ../../opt/openarena/openarena-runner.sh /usr/bin/openarena-server
}
