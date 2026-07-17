# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..14} )

inherit git-r3 python-single-r1

DESCRIPTION="an ad-hoc single file webserver"
HOMEPAGE="https://www.home.unix-ag.org/simon/woof.html https://github.com/simon-budig/woof"
EGIT_REPO_URI="https://github.com/simon-budig/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="~amd64 ~x86"

IUSE="+gzip +bzip2 +unzip"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	gzip? ( app-arch/gzip )
	bzip2? ( app-arch/bzip2 )
	unzip? ( app-arch/unzip )
"

RDEPEND="
	${DEPEND}
	${PYTHON_DEPS}
"

src_install(){
	python_doscript ${PN}
}
