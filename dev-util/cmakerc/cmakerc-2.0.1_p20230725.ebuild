# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

COMMIT_ID="952ffddba731fc110bd50409e8d2b8a06abbd237"
DESCRIPTION="A Resource Compiler in a Single CMake Script"
HOMEPAGE="https://github.com/vector-of-bool/cmrc"
SRC_URI="https://github.com/vector-of-bool/cmrc/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/cmrc-${COMMIT_ID}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

PATCHES=(
	"${FILESDIR}/cmakerc-2.0.1-CMakeLists-minimum-version.patch"
	"${FILESDIR}/cmakerc-2.0.1-installation.patch"
)
