# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 22 )
RUST_MIN_VER="1.87.0"

declare -A GIT_CRATES=(
	[mlua-extra]="https://github.com/hypengw/mlua-extra;16fc20f1445e6b723da78fb08b236dfeaad10db0"
)

inherit toolchain-funcs flag-o-matic llvm-r2 cargo cmake xdg-utils

DESCRIPTION="A dynamic wallpaper solution for Linux desktops"
HOMEPAGE="https://github.com/waywallen/waywallen"

RSTD_COMMIT="629bda81eb98856ca023f0f87f57dde8d22b4823"
WAVSEN_COMMIT="aab112235e4da7e03c233793a9d612507f0e6355"
NCREQUEST_COMMIT="404868aa2aa4481e262f25d8f7d053f42b61b7b8"
QEXTRA_COMMIT="d02d9a7bfed546dfb7f87a5627b1c9e8f6fcc95a"

SRC_URI="
	https://github.com/waywallen/waywallen/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/waywallen/releases/download/v${PV}/waywallen-${PV}-crates.tar.xz
	${CARGO_CRATE_URIS}
	https://github.com/hypengw/rstd/archive/${RSTD_COMMIT}.tar.gz -> rstd-${RSTD_COMMIT}.tar.gz
	https://github.com/hypengw/wavsen/archive/${WAVSEN_COMMIT}.tar.gz -> wavsen-${WAVSEN_COMMIT}.tar.gz
	ui? (
		https://github.com/hypengw/ncrequest/archive/${NCREQUEST_COMMIT}.tar.gz -> ncrequest-${NCREQUEST_COMMIT}.tar.gz
		https://github.com/hypengw/QExtra/archive/${QEXTRA_COMMIT}.tar.gz -> QExtra-${QEXTRA_COMMIT}.tar.gz
	)
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+ui pipewire vaapi"

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
	)
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
	"${FILESDIR}/${PN}-0.2.2-use-system-depends.patch"
)

export LIBSQLITE3_SYS_USE_PKG_CONFIG=1

src_prepare() {
	default_src_prepare

	pushd "${WORKDIR}/rstd-${RSTD_COMMIT}" || die
	eapply "${FILESDIR}/${PN}-0.2.3-rstd-fixes.patch"
	popd || die

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
		-DFETCHCONTENT_SOURCE_DIR_RSTD="${WORKDIR}/rstd-${RSTD_COMMIT}"
		-DFETCHCONTENT_SOURCE_DIR_WAVSEN="${WORKDIR}/wavsen-${WAVSEN_COMMIT}"
		-DWAYWALLEN_BUILD_UI="$(usex ui)"
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
