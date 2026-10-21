# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake tmpfiles linux-info desktop xdg

MY_PV="${PV//0_beta/B}"
MY_PV="${MY_PV//_/-}"

DESCRIPTION="A low latency KVMFR application for guests with VGA PCI Passthrough"
HOMEPAGE="https://looking-glass.io"
SRC_URI="https://looking-glass.io/artifact/${MY_PV}/source -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="X wayland pipewire pulseaudio +backtrace gnome host obs"
REQUIRED_USE="|| ( X wayland )
	|| ( pipewire pulseaudio )"

DEPEND="gui-libs/egl-wayland
	media-libs/fontconfig
	media-libs/libsamplerate
	dev-libs/nettle[gmp]
	app-emulation/spice-protocol
	sys-libs/binutils-libs
	media-libs/libglvnd[X]
	X? (
		x11-libs/libX11
		x11-libs/libXfixes
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXcursor
		x11-libs/libXScrnSaver
		x11-libs/libXpresent
	)
	wayland? (
		dev-libs/wayland
		x11-libs/libxkbcommon
		gnome? (
			gui-libs/libdecor
		)
	)
	pipewire? (
		media-video/pipewire
	)
	pulseaudio? (
		media-libs/libpulse
	)
	obs? (
		media-video/obs-studio
	)"
RDEPEND="
	${DEPEND}
	acct-user/qemu
"

MY_CMAKE_PROJECT="client "

src_prepare() {
	default
	# fix cmake compatibility issues with newer cmake versions
	find "${S}" -name "CMakeLists.txt" -exec sed -i \
		's/cmake_minimum_required(VERSION 3\.5)/cmake_minimum_required(VERSION 3.10)/' {} +
	find "${S}" -name "CMakeLists.txt" -exec sed -i \
		's/cmake_minimum_required(VERSION [0-9]\.[0-9])/cmake_minimum_required(VERSION 3.10)/' {} +
	# add other project
	if use host; then
		MY_CMAKE_PROJECT+="host "
	fi
	if use obs; then
		MY_CMAKE_PROJECT+="obs "
	fi
	# cmake prepare loop
	for prj in ${MY_CMAKE_PROJECT}
	do
		CMAKE_USE_DIR="${S}/${prj}"
		cmake_src_prepare "$@"
	done
}

src_configure() {
	# cmake configure by use flags
	if ! use X; then
		local mycmakeargs+=(
			-DENABLE_X11=no
		)
	fi
	if use wayland; then
		local mycmakeargs+=(
			-DENABLE_WAYLAND=yes
		)
	fi
	if ! use pipewire; then
		local mycmakeargs+=(
			-DENABLE_PIPEWIRE=no
		)
	fi
	if ! use pulseaudio; then
		local mycmakeargs+=(
			-DENABLE_PULSEAUDIO=no
		)
	fi
	if use gnome && use wayland; then
		local mycmakeargs+=(
			-DENABLE_LIBDECOR=yes
		)
	fi
	# cmake configure loop
	for prj in ${MY_CMAKE_PROJECT}
	do
		CMAKE_USE_DIR="${S}/${prj}"
		BUILD_DIR="${WORKDIR}/${prj}"
		cmake_src_configure "$@"
	done
	set_arch_to_kernel
}

src_compile() {
	# cmake compile loop
	for prj in ${MY_CMAKE_PROJECT}
	do
		CMAKE_USE_DIR="${S}/${prj}"
		BUILD_DIR="${WORKDIR}/${prj}"
		cmake_src_compile "$@"
	done
}

src_install() {
	# install cmake projects
	for prj in ${MY_CMAKE_PROJECT}
	do
		CMAKE_USE_DIR="${S}/${prj}"
		BUILD_DIR="${WORKDIR}/${prj}"
		cmake_src_install "$@"
	done
	# install docs
	einstalldocs
	# install tmpfiles config
	newtmpfiles "${FILESDIR}"/${PN}-tmpfiles.conf ${PN}.conf
	# install desktop
	domenu "${FILESDIR}/${PN}.desktop"
	newicon -s 128 "${S}/resources/icon-128x128.png" "${PN}.png"
}

pkg_postinst() {
	xdg_pkg_postinst
	tmpfiles_process ${PN}.conf
}
