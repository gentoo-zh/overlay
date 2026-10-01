# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Reformats Java source code to comply with Google Java Style"
HOMEPAGE="https://github.com/google/google-java-format"
SRC_URI="https://github.com/google/google-java-format/releases/download/v${PV}/${P}-all-deps.jar"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="virtual/jdk:17"
DEPEND="${RDEPEND}"

src_install() {
	insinto "/usr/share/${PN}"
	newins "${DISTDIR}/${P}-all-deps.jar" "google-java-format-all-deps.jar"

	dobin "${FILESDIR}/${PN}"
}
