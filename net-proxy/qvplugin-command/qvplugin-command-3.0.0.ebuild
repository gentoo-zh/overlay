# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Plugin for Qv2ray to run any commands when something happens in Qv2ray"
HOMEPAGE="https://github.com/Qv2ray/QvPlugin-Command"
GIT_COMMIT_QVPLUGIN_INTERFACE="911c4adbb7b598435162da245ab248d215d3f018"
GIT_COMMIT_QJSONSTRUCT="02416895f2f1fb826f8e9207d8bbe5804b6d0441"
SRC_URI="
	https://github.com/Qv2ray/QvPlugin-Command/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/Qv2ray/QvPlugin-Interface/archive/${GIT_COMMIT_QVPLUGIN_INTERFACE}.tar.gz
		-> QvPlugin-Interface-${GIT_COMMIT_QVPLUGIN_INTERFACE}.tar.gz
	https://github.com/Qv2ray/QJsonStruct/archive/${GIT_COMMIT_QJSONSTRUCT}.tar.gz
		-> QJsonStruct-${GIT_COMMIT_QJSONSTRUCT}.tar.gz
"

S="${WORKDIR}/QvPlugin-Command-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-qt/qtbase:6[gui,widgets]"
RDEPEND="
	>=net-proxy/qv2ray-2.7.0
	${DEPEND}
"

src_unpack() {
	default
	rmdir "${S}/interface" || die
	mv "${WORKDIR}/QvPlugin-Interface-${GIT_COMMIT_QVPLUGIN_INTERFACE}" "${S}/interface" || die
	rmdir "${S}/lib/QJsonStruct" || die
	mv "${WORKDIR}/QJsonStruct-${GIT_COMMIT_QJSONSTRUCT}" "${S}/lib/QJsonStruct" || die
}

src_prepare() {
	# ensure cmake_minimum_required >=3.10 (Bug: 951350, 964405)
	sed -e '/cmake_minimum_required/s/3\.1\.0/3.10/' \
		-i CMakeLists.txt interface/Qv{,GUI}PluginInterface.cmake || die
	sed -e '/cmake_minimum_required/s/3\.5/3.10/' -i lib/QJsonStruct/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DQVPLUGIN_USE_QT6=ON
	)
	cmake_src_configure
}

src_install(){
	insinto "/usr/share/qv2ray/plugins"
	insopts -m755
	doins "${BUILD_DIR}/libQvPlugin-Command.so"
}
