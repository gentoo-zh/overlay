# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Arch Linux install tools (pacstrap, genfstab, arch-chroot)"
HOMEPAGE="https://gitlab.archlinux.org/archlinux/arch-install-scripts"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+archroot +genfstab +pacstrap"

RDEPEND="
	archroot? ( sys-apps/arch-chroot )
	genfstab? ( sys-fs/genfstab )
	pacstrap? ( dev-util/pacstrap )
"
