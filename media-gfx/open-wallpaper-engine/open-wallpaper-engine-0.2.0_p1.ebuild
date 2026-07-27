# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 22 )

inherit toolchain-funcs flag-o-matic llvm-r2 cmake

DESCRIPTION="A dynamic wallpaper solution for Linux desktops"
HOMEPAGE="https://github.com/waywallen/open-wallpaper-engine"

EIGEN_TAG="5.0.1"
SPIRV_REFLECT_TAG="1.4.321.0"
VMA_TAG="3.4.0"
RSTD_COMMIT="bf5f855ddb1b84390306e0913b89149ac72a3510"
VVK_COMMIT="8fcfd34b43a13ade515f029b0b4209bd3684645f"
WAVSEN_COMMIT="e49fc62fdc1b57abeabb643daa6ebab96fb3821f"
CEF_FILENAME="cef_binary_149.0.4+g2f1bfd8+chromium-149.0.7827.156_linux64_minimal"

SRC_URI="
	https://github.com/waywallen/open-wallpaper-engine/archive/refs/tags/v${PV/_p1/-fix}.tar.gz -> ${P}.tar.gz
	https://gitlab.com/libeigen/eigen/-/archive/${EIGEN_TAG}/eigen-${EIGEN_TAG}.tar.bz2
	https://github.com/KhronosGroup/SPIRV-Reflect/archive/vulkan-sdk-${SPIRV_REFLECT_TAG}.tar.gz
		-> SPIRV-Reflect-${SPIRV_REFLECT_TAG}.tar.gz
	https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/v${VMA_TAG}.tar.gz
		-> VulkanMemoryAllocator-${VMA_TAG}.tar.gz
	https://github.com/litocpp/rstd/archive/${RSTD_COMMIT}.tar.gz -> rstd-${RSTD_COMMIT}.tar.gz
	https://github.com/litocpp/vvk/archive/${VVK_COMMIT}.tar.gz -> vvk-${VVK_COMMIT}.tar.gz
	https://github.com/hypengw/wavsen/archive/${WAVSEN_COMMIT}.tar.gz -> wavsen-${WAVSEN_COMMIT}.tar.gz
	web? ( https://cef-builds.spotifycdn.com/${CEF_FILENAME}.tar.bz2 )
"

S="${WORKDIR}/${P/_p1/-fix}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+scene +web +waywallen pipewire vaapi"
REQUIRED_USE="|| ( scene web )"

RDEPEND="
	dev-libs/icu
	virtual/zlib
	media-libs/mesa
	media-libs/vulkan-loader
	media-video/ffmpeg
	dev-libs/glib
	dev-util/glslang
	app-arch/lz4
	scene? ( dev-libs/quickjs-ng )
	web? (
		dev-libs/nspr
		dev-libs/nss
	)
	waywallen? ( gui-apps/waywallen )
	pipewire? ( media-video/pipewire )
	!pipewire? ( media-libs/libpulse )
	vaapi? ( media-libs/libva )
"
DEPEND="
	${RDEPEND}
	dev-util/vulkan-headers
"
BDEPEND="
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}=
		llvm-core/lld:${LLVM_SLOT}=
	')
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-0.2.0-use-system-depends.patch"
	"${FILESDIR}/${PN}-0.1.9-fix-waywallen-plugin-install-path.patch"
	"${FILESDIR}/${PN}-0.1.9-disable-viewer-default.patch"
)

src_prepare() {
	default_src_prepare

	pushd "${WORKDIR}/wavsen-${WAVSEN_COMMIT}" || die
	eapply "${FILESDIR}/${PN}-0.1.9-wavsen-optional-vaapi.patch"
	popd || die

	if use web; then
		pushd "${WORKDIR}/${CEF_FILENAME}" || die
		eapply "${FILESDIR}/${PN}-0.1.9-cef-remove-march.patch"
		eapply "${FILESDIR}/${PN}-0.1.9-let-libcef_dll_wrapper-static.patch"
		popd || die
	fi

	cmake_prepare
}

src_configure() {
	export \
		CC="clang-${LLVM_SLOT}" \
		CXX="clang++-${LLVM_SLOT}"

	append-cxxflags -D_FORTIFY_SOURCE=0

	if ! tc-ld-is-lld && ! tc-ld-is-mold; then
		append-ldflags -fuse-ld=lld
	fi

	local mycmakeargs=(
		-DCMAKE_LINKER_TYPE=LLD
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_SOURCE_DIR_EIGEN="${WORKDIR}/eigen-${EIGEN_TAG}"
		-DFETCHCONTENT_SOURCE_DIR_SPIRV_REFLECT="${WORKDIR}/SPIRV-Reflect-vulkan-sdk-${SPIRV_REFLECT_TAG}"
		-DFETCHCONTENT_SOURCE_DIR_VMA="${WORKDIR}/VulkanMemoryAllocator-${VMA_TAG}"
		-DFETCHCONTENT_SOURCE_DIR_RSTD="${WORKDIR}/rstd-${RSTD_COMMIT}"
		-DFETCHCONTENT_SOURCE_DIR_VVK="${WORKDIR}/vvk-${VVK_COMMIT}"
		-DFETCHCONTENT_SOURCE_DIR_WAVSEN="${WORKDIR}/wavsen-${WAVSEN_COMMIT}"
		-DFETCHCONTENT_SOURCE_DIR_CEF="${WORKDIR}/${CEF_FILENAME}"
		-DBUILD_WESCENE="$(usex scene)"
		-DBUILD_WEWEB="$(usex web)"
		-DBUILD_WAYWALLEN="$(usex waywallen)"
		-DWAVSEN_AUDIO_BACKEND="$(usex pipewire pipewire pulse)"
		-DWAVSEM_USE_VAAPI="$(usex vaapi)"
	)

	cmake_src_configure
}
