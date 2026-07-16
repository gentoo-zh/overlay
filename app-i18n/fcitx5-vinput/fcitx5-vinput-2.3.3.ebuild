# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake optfeature xdg

# Prebuilt sherpa-onnx runtime shared libraries bundled by upstream. The
# project links against these and installs them privately under
# /usr/lib*/fcitx5-vinput. Keep in sync with scripts/sherpa-onnx-vars.sh.
SHERPA_PV=1.13.3

DESCRIPTION="Voice input addon for Fcitx5 with local sherpa-onnx ASR and LLM postprocess"
HOMEPAGE="https://github.com/xifan2333/fcitx5-vinput"
SRC_URI="
	https://github.com/xifan2333/fcitx5-vinput/archive/v${PV}/${P}.tar.gz
	amd64? ( https://github.com/k2-fsa/sherpa-onnx/releases/download/v${SHERPA_PV}/sherpa-onnx-v${SHERPA_PV}-linux-x64-shared-no-tts.tar.bz2 )
	arm64? ( https://github.com/k2-fsa/sherpa-onnx/releases/download/v${SHERPA_PV}/sherpa-onnx-v${SHERPA_PV}-linux-aarch64-shared-cpu.tar.bz2 )
"

# fcitx5-vinput: GPL-3; bundled sherpa-onnx: Apache-2.0; bundled onnxruntime
# and the silero VAD model (data/vad/silero_vad.onnx): MIT.
LICENSE="GPL-3 Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="systemd"

# Bundled prebuilt sherpa-onnx/onnxruntime shared libraries.
QA_PREBUILT="usr/lib*/fcitx5-vinput/*"
RESTRICT="strip"

# The daemon needs sd-bus. Build it against libsystemd on systemd systems
# and elogind's libelogind everywhere else, so the addon stays installable
# on OpenRC profiles too.
COMMON_DEPEND="
	app-arch/libarchive:=
	app-i18n/fcitx:5
	dev-libs/openssl:=
	dev-qt/qtbase:6[gui,network,widgets]
	media-video/pipewire
	net-misc/curl
	systemd? ( sys-apps/systemd:= )
	!systemd? ( sys-auth/elogind:= )
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="
	${COMMON_DEPEND}
	dev-cpp/cli11
	dev-cpp/nlohmann_json
"
BDEPEND="
	dev-qt/qttools:6[linguist]
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-2.3.2-sdbus-provider.patch
)

src_configure() {
	local sherpa_dir
	if use amd64; then
		sherpa_dir="${WORKDIR}/sherpa-onnx-v${SHERPA_PV}-linux-x64-shared-no-tts"
	elif use arm64; then
		sherpa_dir="${WORKDIR}/sherpa-onnx-v${SHERPA_PV}-linux-aarch64-shared-cpu"
	fi

	# Without a systemd profile, build sd-bus against libelogind instead.
	local sdbus_provider=libelogind
	use systemd && sdbus_provider=libsystemd

	local mycmakeargs=(
		-DVINPUT_PROJECT_VERSION="${PV}"
		-DVINPUT_PACKAGE_RELEASE="1"
		-DVINPUT_PACKAGE_HOMEPAGE_URL="${HOMEPAGE}"
		-DVINPUT_RUNTIME_MODE="bundled"
		-DVINPUT_FETCH_CLI11="OFF"
		-DVINPUT_SDBUS_PROVIDER="${sdbus_provider}"
		-DCMAKE_PREFIX_PATH="${sherpa_dir}"
	)

	cmake_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "output volume reduction while recording" media-video/wireplumber
}
