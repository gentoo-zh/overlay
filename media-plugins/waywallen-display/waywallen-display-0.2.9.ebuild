# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CARGO_OPTIONAL=1

inherit cargo cmake

DESCRIPTION="Desktop integration for the waywallen wallpaper daemon"
HOMEPAGE="https://github.com/waywallen/waywallen-display"

SRC_URI="
	https://github.com/waywallen/waywallen-display/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	layer? ( https://github.com/gentoo-zh-drafts/waywallen-display/releases/download/v${PV}/${P}-crates.tar.xz )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+egl vulkan +layer gnome plasma"
REQUIRED_USE="
	|| ( egl vulkan )
	|| ( layer gnome plasma )
"

RDEPEND="
	dev-libs/icu
	virtual/zlib
	media-video/ffmpeg
	dev-libs/glib
	egl? (
		media-libs/libglvnd
		media-libs/mesa
	)
	vulkan? ( media-libs/vulkan-loader )
	gnome? ( gui-libs/gtk )
	plasma? (
		dev-qt/qtbase:6[dbus,gui]
		dev-qt/qtdeclarative:6
	)
"
DEPEND="
	${RDEPEND}
	vulkan? ( dev-util/vulkan-headers )
"
BDEPEND="
	virtual/pkgconfig
	layer? ( ${RUST_DEPEND} )
"

src_unpack() {
	default
	cargo_src_unpack
}

src_configure() {
	local mycmakeargs=(
		-DWAYWALLEN_DISPLAY_WITH_EGL="$(usex egl)"
		-DWAYWALLEN_DISPLAY_WITH_VULKAN="$(usex vulkan)"
		-DWAYWALLEN_DISPLAY_PLUGIN_QML="$(usex plasma)"
		-DWAYWALLEN_DISPLAY_PLUGIN_GOBJECT="$(usex gnome)"
		-DWAYWALLEN_DISPLAY_PLUGIN_GNOME="$(usex gnome)"
	)
	cmake_src_configure

	if use layer; then
		local myfeatures=(
			layer-shell
			$(usev egl)
			$(usev vulkan)
		)
		cargo_src_configure --bin waywallen-layer-shell --no-default-features
	fi
}

src_compile() {
	cmake_src_compile
	use layer && cargo_src_compile
}

src_install() {
	cmake_src_install
	use layer && cargo_src_install --bin waywallen-layer-shell
	if use plasma; then
		insinto /usr/share/plasma/wallpapers/org.waywallen.kde
		doins -r extensions/kde/package/*
	fi
}
