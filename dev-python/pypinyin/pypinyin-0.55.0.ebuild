# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} pypy3 )

inherit distutils-r1

DESCRIPTION="Tool for converting Chinese characters to pinyin"
HOMEPAGE="
	https://github.com/mozillazg/python-pinyin
	https://pypi.org/project/pypinyin
"
SRC_URI="https://github.com/mozillazg/python-pinyin/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

S="${WORKDIR}/python-pinyin-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare
	sed -i '/^universal=1$/d' setup.cfg || die
	sed -i '/License ::/d' setup.py || die
	sed -i -e '/--cov/d' pytest.ini || die
}

python_test() {
	epytest -s
}
