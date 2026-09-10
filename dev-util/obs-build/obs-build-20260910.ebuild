# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="OBS build script"
HOMEPAGE="https://github.com/openSUSE/obs-build"
SRC_URI="https://github.com/openSUSE/obs-build/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-arch/rpm
	dev-lang/perl
"
