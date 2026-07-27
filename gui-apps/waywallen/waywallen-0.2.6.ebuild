# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 22 )
RUST_MIN_VER="1.88.0"

declare -A GIT_CRATES=(
	[mlua-extra]="https://github.com/hypengw/mlua-extra;df1d282170dd1718b8aeff405638c18cedd435ca"
)

inherit toolchain-funcs flag-o-matic llvm-r2 cargo cmake xdg-utils

DESCRIPTION="A dynamic wallpaper solution for Linux desktops"
HOMEPAGE="https://github.com/waywallen/waywallen"

VMA_TAG="3.4.0"
RSTD_COMMIT="bf5f855ddb1b84390306e0913b89149ac72a3510"
VVK_COMMIT="8fcfd34b43a13ade515f029b0b4209bd3684645f"
WAVSEN_COMMIT="e49fc62fdc1b57abeabb643daa6ebab96fb3821f"
NCREQUEST_COMMIT="37d3c588fb1307dd6c40fbc8681790b45eb5402a"
QEXTRA_COMMIT="2106172c8c55693248661f5ddfc0623ff489285d"

SRC_URI="
	https://github.com/waywallen/waywallen/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/waywallen/releases/download/v${PV}/waywallen-${PV}-crates.tar.xz
	${CARGO_CRATE_URIS}
	https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/v${VMA_TAG}.tar.gz
		-> VulkanMemoryAllocator-${VMA_TAG}.tar.gz
	https://github.com/litocpp/rstd/archive/${RSTD_COMMIT}.tar.gz -> rstd-${RSTD_COMMIT}.tar.gz
	https://github.com/litocpp/vvk/archive/${VVK_COMMIT}.tar.gz -> vvk-${VVK_COMMIT}.tar.gz
	https://github.com/hypengw/wavsen/archive/${WAVSEN_COMMIT}.tar.gz -> wavsen-${WAVSEN_COMMIT}.tar.gz
	ui? (
		https://github.com/hypengw/ncrequest/archive/${NCREQUEST_COMMIT}.tar.gz -> ncrequest-${NCREQUEST_COMMIT}.tar.gz
		https://github.com/hypengw/QExtra/archive/${QEXTRA_COMMIT}.tar.gz -> QExtra-${QEXTRA_COMMIT}.tar.gz
	)
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+ui mpv pipewire vaapi +wallhaven"

RDEPEND="
	media-plugins/waywallen-display
	dev-db/sqlite
	dev-libs/glib
	dev-libs/icu
	dev-libs/protobuf
	dev-util/glslang
	media-libs/mesa
	media-libs/vulkan-loader
	media-video/ffmpeg
	net-misc/curl
	virtual/zlib
	ui? (
		dev-libs/qml-material:=
		dev-qt/qtbase:6[dbus]
		dev-qt/qtdeclarative:6
		dev-qt/qtgrpc:6
		dev-qt/qtwebsockets:6
	)
	mpv? ( media-video/mpv )
	pipewire? ( media-video/pipewire )
	!pipewire? ( media-libs/libpulse )
	vaapi? ( media-libs/libva )
"
DEPEND="
	${RDEPEND}
	dev-cpp/asio
	dev-cpp/nlohmann_json
	dev-libs/pegtl
	dev-util/vulkan-headers
"
BDEPEND="
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}=
		llvm-core/lld:${LLVM_SLOT}=
	')
	>=dev-build/corrosion-0.6.1
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-0.2.6-use-system-depends.patch"
)

export LIBSQLITE3_SYS_USE_PKG_CONFIG=1

src_prepare() {
	default_src_prepare

	pushd "${WORKDIR}/wavsen-${WAVSEN_COMMIT}" || die
	eapply "${FILESDIR}/${PN}-0.2.2-wavsen-optional-vaapi.patch"
	popd || die

	cmake_prepare
}

src_configure() {
	export \
		CC="clang-${LLVM_SLOT}" \
		CXX="clang++-${LLVM_SLOT}"

	# Fix link error when use -O1 ~ -O3
	append-cxxflags -D_FORTIFY_SOURCE=0

	if ! tc-ld-is-lld && ! tc-ld-is-mold; then
		append-ldflags -fuse-ld=lld
	fi

	local mycmakeargs=(
		-DCMAKE_LINKER_TYPE=LLD
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_SOURCE_DIR_VMA="${WORKDIR}/VulkanMemoryAllocator-${VMA_TAG}"
		-DFETCHCONTENT_SOURCE_DIR_RSTD="${WORKDIR}/rstd-${RSTD_COMMIT}"
		-DFETCHCONTENT_SOURCE_DIR_VVK="${WORKDIR}/vvk-${VVK_COMMIT}"
		-DFETCHCONTENT_SOURCE_DIR_WAVSEN="${WORKDIR}/wavsen-${WAVSEN_COMMIT}"
		-DWAYWALLEN_BUILD_UI="$(usex ui)"
		-DWAYWALLEN_BUILD_MPV_PLUGIN="$(usex mpv)"
		-DWAYWALLEN_INSTALL_WALLHAVEN_PLUGIN="$(usex wallhaven)"
		-DWAVSEN_AUDIO_BACKEND="$(usex pipewire pipewire pulse)"
		-DWAVSEM_USE_VAAPI="$(usex vaapi)"
	)

	use ui && mycmakeargs+=(
		-DFETCHCONTENT_SOURCE_DIR_NCREQUEST="${WORKDIR}/ncrequest-${NCREQUEST_COMMIT}"
		-DFETCHCONTENT_SOURCE_DIR_QEXTRA="${WORKDIR}/QExtra-${QEXTRA_COMMIT}"
	)

	cmake_src_configure
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
