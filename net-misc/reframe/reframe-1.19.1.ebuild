# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson tmpfiles

MVMATH_COMMIT="e7547696c8345dcdbc65fd31c51d05d1dc4e1e1a"

DESCRIPTION="DRM/KMS based remote desktop for Linux"
HOMEPAGE="https://reframe.alynx.one/"
SRC_URI="
	https://github.com/AlynxZhou/reframe/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/AlynxZhou/mvmath/archive/${MVMATH_COMMIT}.tar.gz -> mvmath-${MVMATH_COMMIT}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="neatvnc systemd"

RDEPEND="
	acct-user/reframe
	acct-group/reframe
	dev-libs/glib:2
	gui-libs/gtk:4
	x11-libs/libdrm
	media-libs/libepoxy
	net-libs/libvncserver
	x11-libs/libxkbcommon
	neatvnc? (
		gui-libs/neatvnc
		dev-libs/aml
		x11-libs/pixman
		media-video/ffmpeg
	)
"
DEPEND="
	${RDEPEND}
"

src_prepare() {
	rm -rf "${S}/deps/mvmath"
	ln -sfn "${WORKDIR}/mvmath-${MVMATH_COMMIT}" "${S}/deps/mvmath"

	default_src_prepare
}

src_configure() {
	local emesonargs=(
		-D neatvnc=$(usex neatvnc true false)
	)

	meson_src_configure
}

pkg_postinst() {
	if use systemd; then
		tmpfiles_process reframe-tmpfiles.conf
	fi
}
