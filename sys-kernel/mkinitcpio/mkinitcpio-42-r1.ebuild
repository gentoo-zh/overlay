# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson tmpfiles

DESCRIPTION="Modular initramfs image creation utility"
HOMEPAGE="https://github.com/archlinux/mkinitcpio"

SRC_URI="https://github.com/archlinux/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64 ~loong ~mips ~x86"

IUSE="systemd"

DEPEND="sys-apps/kmod
sys-apps/util-linux
app-arch/libarchive
app-arch/zstd
sys-apps/busybox
sys-apps/coreutils
sys-apps/findutils
sys-apps/sed
app-alternatives/awk
sys-apps/baselayout
virtual/tmpfiles
virtual/udev
systemd? ( sys-apps/systemd )
"

RDEPEND="${DEPEND}"

BDEPEND="
	>=dev-build/meson-1.4.0
	sys-apps/busybox
	app-arch/libarchive
	app-text/asciidoc
	sys-apps/sed
	virtual/pkgconfig
"

QA_PREBUILT="/usr/lib/initcpio/busybox"

src_prepare() {
	default
	# tools/dist.sh reads the version from git describe, which the tarball lacks
	sed -i "s|run_command('tools/dist.sh', 'get-version', check: true).stdout().strip()|'${PV}'|" \
		meson.build || die
	sed -i "s:/usr/lib/libkmod.so.2:/usr/$(get_libdir)/libkmod.so.2:" install/udev || die
	# libgcc_s lives under the active gcc's libdir, resolve it when the image is built
	local libgcc='add_binary "$(gcc-config -L | cut -d: -f1)/libgcc_s.so.1" /usr/lib/libgcc_s.so.1'
	sed -i \
		-e "/add_binary.*libgcc_s\.so\.1/s#.*#    ${libgcc}#" \
		-e "s:/usr/lib/ossl-modules/legacy.so:/usr/$(get_libdir)/ossl-modules/legacy.so:" \
		install/encrypt || die
}

src_configure() {
	local -x PATH="/usr/lib/systemd:${PATH}"
	local emesonargs=(
		--libdir lib
		$(meson_feature systemd)
	)
	meson_src_configure
}

src_install(){
	meson_src_install
	exeinto /usr/lib/initcpio/
	doexe /bin/busybox
	insinto /usr/lib/initcpio/install
	if use systemd; then
		sed 's|^    add_file /etc/machine-info$|    [[ -f /etc/machine-info ]] \&\& add_file /etc/machine-info|' \
			"${FILESDIR}"/initcpio-install-systemd > "${T}"/initcpio-install-systemd || die
		newins "${T}"/initcpio-install-systemd systemd
	fi
	insinto /usr/lib/initcpio/hooks
	newins "${FILESDIR}"/initcpio-hook-udev udev
	insinto /etc/mkinitcpio.d
	doins "${FILESDIR}"/linux.preset
}

pkg_postinst() {
	use systemd && tmpfiles_process 20-mkinitcpio.conf
}
