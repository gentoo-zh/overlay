# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_VERSION="${PV/_alpha/-alpha.}"
MY_VERSION="${MY_VERSION/_beta/-beta.}"
MY_VERSION="${MY_VERSION/_rc/-rc.}"
MY_TAG="v${MY_VERSION}"
MY_URI="https://github.com/Zakkaus/doona/releases/download/${MY_TAG}"
DESCRIPTION="Web UI for the daeuniverse engines"
HOMEPAGE="https://github.com/Zakkaus/doona"
SRC_URI="
	${MY_URI}/${PN}-${MY_VERSION}.tar.gz -> ${P}.tar.gz
	fonts? ( ${MY_URI}/${PN}-fonts-${MY_VERSION}.tar.gz -> ${P}-fonts.tar.gz )
"
S="${WORKDIR}"

# The built files bundle npm packages, icons, palette images and a flag font under these licenses.
LICENSE="GPL-3 0BSD Apache-2.0 CC-BY-3.0 CC-BY-4.0 CC-BY-SA-4.0 CC0-1.0 ISC MIT fonts? ( OFL-1.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
IUSE="+fonts"

src_install() {
	dodoc NOTICE README.md
	dodoc -r LICENSES
	# Archives up to 0.1.0-beta.14 also carry the changelog.
	if [[ -f CHANGELOG.md ]]; then
		dodoc CHANGELOG.md
		rm CHANGELOG.md || die
	fi
	rm -r LICENSE LICENSES NOTICE README.md || die
	insinto /usr/share/"${PN}"
	doins -r .
}

pkg_postinst() {
	elog "Point the engine's native API ui setting (honk: experimental.native_api.ui)"
	elog "at /usr/share/${PN}, or serve that directory with a web server."
}
