# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake xdg

DESCRIPTION="Cool dock (desktop panel) for Linux desktop"
HOMEPAGE="https://github.com/dangvd/crystal-dock"
SRC_URI="
	https://github.com/dangvd/crystal-dock/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
"
S="${WORKDIR}/${P}/src"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	>=dev-libs/wayland-1.22
	>=dev-qt/qtbase-6.6:6[dbus,gui,widgets]
	dev-util/vulkan-headers
	kde-plasma/layer-shell-qt:6
	x11-libs/libxkbcommon
"
RDEPEND="${DEPEND}"
