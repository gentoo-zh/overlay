# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Generate Cython pxd files from C header files"
HOMEPAGE="
	https://github.com/elijahr/python-autopxd2
	https://pypi.org/project/autopxd2/
"

SRC_URI="https://github.com/elijahr/python-autopxd2/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

S="${WORKDIR}/python-autopxd2-${PV}"

LICENSE="MIT"
SLOT="0"

KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/headerkit[${PYTHON_USEDEP}]
	llvm-core/clang
"
BDEPEND="
	test? (
		dev-python/cython[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-timeout )

distutils_enable_tests pytest

python_test() {
	epytest -m "not real_headers and not treesitter" -k "not tree-sitter"
}

src_prepare() {
	default

	# Fix deprecated project.license table format (PEP 639)
	sed -i 's/^license = { file = "LICENSE" }/license = "MIT"/' pyproject.toml || die
}
