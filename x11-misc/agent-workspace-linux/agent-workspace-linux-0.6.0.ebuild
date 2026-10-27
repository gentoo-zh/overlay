# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=""

declare -A GIT_CRATES=(
	[collections]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/collections'
	[cosmic-client-toolkit]='https://github.com/pop-os/cosmic-protocols;c0cff4db14c37ed954983158e4055aa94c7741d9;cosmic-protocols-%commit%/client-toolkit'
	[cosmic-protocols]='https://github.com/pop-os/cosmic-protocols;c0cff4db14c37ed954983158e4055aa94c7741d9;cosmic-protocols-%commit%'
	[derive_refineable]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/refineable/derive_refineable'
	[gpui]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui'
	[gpui_apple]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_apple'
	[gpui_ios]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_ios'
	[gpui_linux]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_linux'
	[gpui_macos]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_macos'
	[gpui_macros]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_macros'
	[gpui_platform]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_platform'
	[gpui_shared_string]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_shared_string'
	[gpui_util]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_util'
	[gpui_web]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_web'
	[gpui_wgpu]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_wgpu'
	[gpui_windows]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/gpui_windows'
	[http_client]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/http_client'
	[naga-types]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/naga-types'
	[naga]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/naga'
	[oo7]='https://github.com/zed-industries/oo7;731c1215edb6905876c6137ab300428c7b8d7c13;oo7-%commit%/client'
	[refineable]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/refineable'
	[scheduler]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/scheduler'
	[sum_tree]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/sum_tree'
	[wgpu-core-deps-apple]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-core/platform-deps/apple'
	[wgpu-core-deps-emscripten]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-core/platform-deps/emscripten'
	[wgpu-core-deps-linux-android-bsd]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-core/platform-deps/linux-android-bsd'
	[wgpu-core-deps-wasm]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-core/platform-deps/wasm'
	[wgpu-core-deps-windows]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-core/platform-deps/windows'
	[wgpu-core]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-core'
	[wgpu-hal]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-hal'
	[wgpu-naga-bridge]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-naga-bridge'
	[wgpu-sync]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-sync'
	[wgpu-types]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu-types'
	[wgpu]='https://github.com/gfx-rs/wgpu;3b3506ea31154edc04de64debda0e780cba2639c;wgpu-%commit%/wgpu'
	[xim-ctext]='https://github.com/zed-industries/xim-rs;16f35a2c881b815a2b6cdfd6687988e84f8447d8;xim-rs-%commit%/xim-ctext'
	[xim-parser]='https://github.com/zed-industries/xim-rs;16f35a2c881b815a2b6cdfd6687988e84f8447d8;xim-rs-%commit%/xim-parser'
	[zed-font-kit]='https://github.com/zed-industries/font-kit;94b0f28166665e8fd2f53ff6d268a14955c82269;font-kit-%commit%'
	[zed-scap]='https://github.com/zed-industries/scap;4afea48c3b002197176fb19cd0f9b180dd36eaac;scap-%commit%'
	[zed-xim]='https://github.com/zed-industries/xim-rs;16f35a2c881b815a2b6cdfd6687988e84f8447d8;xim-rs-%commit%'
	[ztracing]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/ztracing'
	[ztracing_macro]='https://github.com/zed-industries/zed;347f171a3fd00a3b672382d78348b37bd969d17c;zed-%commit%/crates/ztracing_macro'
)

# The wgpu workspace requires rust-version 1.93.
RUST_MIN_VER="1.93"

inherit cargo optfeature

DESCRIPTION="Isolated X11 workspaces in which an agent runs and observes apps"
HOMEPAGE="https://github.com/agent-sh/agent-workspace-linux"
SRC_URI="
	https://github.com/agent-sh/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD CC0-1.0 ISC MIT MPL-2.0 UoI-NCSA Unicode-3.0
	ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-libs/fontconfig
	x11-apps/xauth
	x11-apps/xdpyinfo
	x11-apps/xprop
	x11-libs/libxcb:=
	x11-libs/libxkbcommon[X]
	x11-misc/xdotool
	x11-base/xorg-server[xvfb]
	|| (
		x11-wm/openbox
		x11-wm/i3
		x11-wm/fluxbox
	)
	|| (
		media-video/ffmpeg
		media-gfx/imagemagick
		media-gfx/scrot
	)
	|| (
		x11-misc/xclip
		x11-misc/xsel
	)
"

DEPEND="${RDEPEND} media-libs/freetype"

BDEPEND="virtual/pkgconfig"

src_install() {
	cargo_src_install
	insinto /usr/share/${PN}
	doins -r skills
}

pkg_postinst() {
	optfeature "accurate window origins" x11-apps/xwininfo
	optfeature "the on-screen workspace viewer" media-libs/vulkan-loader media-libs/libglvnd dev-libs/wayland
	optfeature "mount and network isolation" sys-apps/bubblewrap
	optfeature "terminal sessions" app-misc/tmux x11-terms/xterm
	optfeature "browser automation" www-client/google-chrome www-client/chromium
}
