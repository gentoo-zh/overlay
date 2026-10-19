# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit java-pkg-2

DESCRIPTION="A XML Language Server"
HOMEPAGE="https://github.com/eclipse-lemminx/lemminx"
SRC_URI="https://download.eclipse.org/lemminx/releases/${PV}/org.eclipse.lemminx-uber.jar -> ${P//-bin}.jar"

S="${DISTDIR}"

LICENSE="EPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=virtual/jre-1.8:*"
BDEPEND="app-arch/unzip"

src_install() {
	java-pkg_newjar "${P//-bin}.jar"
	java-pkg_dolauncher lemminx
}
