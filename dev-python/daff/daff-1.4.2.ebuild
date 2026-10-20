# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} pypy3 )

inherit distutils-r1 pypi

DESCRIPTION="The daff can produce and apply tabular diffs"
HOMEPAGE="https://github.com/paulfitz/daff"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv ~sparc ~x86"

IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	test? (
		$(python_gen_impl_dep sqlite)
	)
"

python_test() {
	local t
	for t in test/test_*.py; do
		"${EPYTHON}" "${t}" || die "${t} failed with ${EPYTHON}"
	done
}
