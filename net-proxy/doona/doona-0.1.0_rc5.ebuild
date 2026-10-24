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
	lite? ( ${MY_URI}/${PN}-lite-${MY_VERSION}.tar.gz -> ${P}-lite.tar.gz )
"
S="${WORKDIR}/${PN}"

# The built files bundle npm packages, icons, palette images and a flag font under these licenses.
LICENSE="
	GPL-3 Apache-2.0 CC-BY-3.0 CC-BY-4.0 CC-BY-SA-4.0 CC0-1.0 ISC MIT public-domain
	fonts? ( OFL-1.1 )
	lite? ( BSD OFL-1.1 )
"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
IUSE="+fonts lite"

src_unpack() {
	mkdir "${S}" || die
	cd "${S}" || die
	unpack ${P}.tar.gz
	use fonts && unpack ${P}-fonts.tar.gz

	# The lite archive also unpacks to its own root, with the same notices
	if use lite; then
		mkdir "${WORKDIR}"/lite || die
		cd "${WORKDIR}"/lite || die
		unpack ${P}-lite.tar.gz
	fi
}

src_install() {
	dodoc NOTICE README.md README.en.md
	dodoc -r LICENSES
	rm -r LICENSE LICENSES NOTICE README.md README.en.md || die
	insinto /usr/share/"${PN}"
	doins -r .

	if use lite; then
		cd "${WORKDIR}"/lite || die
		rm -r LICENSE LICENSES NOTICE README.md README.en.md || die
		# honk's native-ui feature reads the lite edition from the -lite
		# sibling of the standard edition's directory
		insinto /usr/share/"${PN}"-lite
		doins -r .
	fi
}

pkg_postinst() {
	elog "Point the engine's native API ui setting (honk: experimental.native_api.ui)"
	elog "at /usr/share/${PN}, or serve that directory with a web server."
	use lite && elog "The lite edition is in /usr/share/${PN}-lite."
}
