# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=""
RUST_MIN_VER="1.89.0"

inherit cargo desktop optfeature toolchain-funcs xdg

DESCRIPTION="A lighter, faster desktop code editor"
HOMEPAGE="https://github.com/DEEIX-AI/Winc https://winc.si"
SRC_URI="
	https://github.com/DEEIX-AI/Winc/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-crates.tar.xz
"
S="${WORKDIR}/Winc-${PV}"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 CC0-1.0 ISC MIT Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-libs/wayland
	media-fonts/dejavu
	media-libs/fontconfig
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-misc/xdg-utils
"
BDEPEND="virtual/pkgconfig"

QA_FLAGS_IGNORED="usr/bin/winc usr/bin/winc-pty usr/lib/winc/*"

pkg_setup() {
	rust_pkg_setup

	if tc-is-lto; then
		export CARGO_PROFILE_RELEASE_LTO=thin
	else
		export CARGO_PROFILE_RELEASE_LTO=false
	fi
	export CARGO_PROFILE_RELEASE_STRIP=false
}

src_compile() {
	cargo_src_compile -p winc -p winc-pty -p winc-server
}

src_test() {
	# Test repositories must not inherit the user's git configuration.
	unset CI
	export GIT_CONFIG_NOSYSTEM=1
	export GIT_CONFIG_GLOBAL=/dev/null
	# Keep the test home outside the snapshot directory under ${T}.
	export HOME="${T}/home"
	mkdir -p "${HOME}" || die
	export RUST_TEST_THREADS=4

	# These tests assume the upstream CI shell, formatter and float setup.
	CARGO_SKIP_TESTS=(
		a_connection_that_cannot_start_the_server_reports_why
		app::snapshot::git::diff::side::each_side_of_a_diff_has_a_horizontal_scrollbar_and_the_two_move_together
		app::snapshot::remote::a_folder_on_a_connected_host_opens_as_the_workspace
		app::snapshot::workspace::watch::large_files_save_in_the_background_and_skip_their_own_write
		bash_without_a_prompt_of_its_own_gets_a_clear_one
		python::only_valid_project_environments_are_selected_in_order
		python::project_environment_is_loaded_after_user_config_and_can_be_deactivated
		tools::format::tests::without_a_sign_the_first_installed_tool_is_used
	)

	cargo_src_test --workspace
}

src_install() {
	dobin "$(cargo_target_dir)/winc" "$(cargo_target_dir)/winc-pty"

	local server
	case ${ARCH} in
		amd64) server="winc-server-Linux-x86_64" ;;
		arm64) server="winc-server-Linux-aarch64" ;;
		*) die "unsupported architecture: ${ARCH}" ;;
	esac
	exeinto /usr/lib/winc
	newexe "$(cargo_target_dir)/winc-server" "${server}"

	domenu release/linux/winc.desktop release/linux/winc-url-handler.desktop
	newicon -s scalable crates/winc-app/assets/icon.svg winc.svg

	insinto /usr/share/kio/servicemenus
	doins release/linux/file-manager/winc-open-file.desktop \
		release/linux/file-manager/winc-open-folder.desktop
	insinto /usr/share/nemo/actions
	doins release/linux/file-manager/winc-open-current-folder.nemo_action \
		release/linux/file-manager/winc-open-file.nemo_action \
		release/linux/file-manager/winc-open-folder.nemo_action

	einstalldocs
	dodoc NOTICE
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "Git integration" dev-vcs/git
	optfeature "SSH remote editing" net-misc/openssh
	optfeature "desktop portal file dialogs" sys-apps/xdg-desktop-portal
}
