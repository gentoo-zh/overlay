# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="Aggregated YouTube/Bilibili/NetEase/QQ Music client (Qt6 desktop)"
HOMEPAGE="https://github.com/HougeLangley/HyperOnlineVideo"
SRC_URI="https://github.com/HougeLangley/HyperOnlineVideo/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/HyperOnlineVideo-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="kde +webengine"

DEPEND="
	dev-qt/qtbase:6=[dbus,gui,network,opengl,widgets]
	kde? ( kde-frameworks/kwindowsystem:6= )
	media-video/mpv:=[libmpv]
	webengine? ( dev-qt/qtwebengine:6=[widgets] )
"
RDEPEND="
	${DEPEND}
	media-video/ffmpeg
	net-misc/yt-dlp
"
BDEPEND="virtual/pkgconfig"

CMAKE_USE_DIR="${S}/desktop"

src_configure() {
	local mycmakeargs=(
		$(cmake_use_find_package kde KF6WindowSystem)
		-DHOV_WEBENGINE=$(usex webengine ON OFF)
	)
	cmake_src_configure
}

src_test() {
	# --queue-selftest leaves the event loop running; --exit-after quits it
	local log="${T}/queue-selftest.log"
	LC_ALL=C QT_QPA_PLATFORM=offscreen \
		timeout 300 "${BUILD_DIR}/hov-qt" --queue-selftest --exit-after 20 \
		> "${log}" 2>&1 || { cat "${log}"; die "queue selftest exited abnormally"; }
	cat "${log}"
	grep -q '^\[SELFTEST\]' "${log}" || die "queue selftest did not run"
	if grep -q '^\[FAIL\]' "${log}"; then
		die "queue selftest failed"
	fi
}
