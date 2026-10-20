# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Plugin for Qv2ray to support Trojan proxy in Qv2ray"
HOMEPAGE="https://github.com/Qv2ray/QvPlugin-Trojan"
GIT_COMMIT_QVPLUGIN_INTERFACE="911c4adbb7b598435162da245ab248d215d3f018"
GIT_COMMIT_QV2RAY_TROJAN="5543591f28074d1e88858d2c40fcea4197b7b711"
SRC_URI="
	https://github.com/Qv2ray/QvPlugin-Trojan/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/Qv2ray/QvPlugin-Interface/archive/${GIT_COMMIT_QVPLUGIN_INTERFACE}.tar.gz
		-> QvPlugin-Interface-${GIT_COMMIT_QVPLUGIN_INTERFACE}.tar.gz
	https://github.com/Qv2ray/trojan/archive/${GIT_COMMIT_QV2RAY_TROJAN}.tar.gz
		-> qv2ray-trojan-${GIT_COMMIT_QV2RAY_TROJAN}.tar.gz
"

S="${WORKDIR}/QvPlugin-Trojan-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="mysql +nat +reuseport +tcpfastopen"

DEPEND="
	dev-qt/qtbase:6[gui,network,widgets]
	dev-libs/boost:=
	dev-libs/openssl:0=
	mysql? ( dev-db/mysql-connector-c:= )
"
RDEPEND="
	>=net-proxy/qv2ray-2.7.0
	${DEPEND}
"

PATCHES=(
	"${FILESDIR}/qvplugin-trojan-3.0.0-boost-1.89.0.patch"
)

src_unpack() {
	default
	rmdir "${S}/interface" || die
	mv "${WORKDIR}/QvPlugin-Interface-${GIT_COMMIT_QVPLUGIN_INTERFACE}" "${S}/interface" || die
	rmdir "${S}/trojan" || die
	mv "${WORKDIR}/trojan-${GIT_COMMIT_QV2RAY_TROJAN}" "${S}/trojan" || die
}

src_prepare() {
	sed -i -e 's/rfc2818_verification/host_name_verification/' trojan/src/core/service.cpp || die
	# ensure cmake_minimum_required >=3.10 (Bug: 951350, 964405)
	sed -e '/cmake_minimum_required/s/3\.1\.0/3.10/' \
		-i CMakeLists.txt interface/Qv{,GUI}PluginInterface.cmake || die
	sed -e '/cmake_minimum_required/s/3\.7\.2/3.10/' -i trojan/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DQVPLUGIN_USE_QT6=ON
		-DENABLE_MYSQL=$(usex mysql)
		-DENABLE_NAT=$(usex nat)
		-DENABLE_REUSE_PORT=$(usex reuseport)
		-DFORCE_TCP_FASTOPEN=$(usex tcpfastopen)
	)
	cmake_src_configure
}

src_install(){
	insinto "/usr/share/qv2ray/plugins"
	insopts -m755
	doins "${BUILD_DIR}/libQvPlugin-Trojan.so"
}
