# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Read Exif metadata from tiff and jpeg files"
HOMEPAGE="https://github.com/ianare/exif-py"
SRC_URI="https://github.com/ianare/exif-py/archive/${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/exif-py-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="${PYTHON_DEPS}"

distutils_enable_tests pytest

python_prepare_all() {
	# setuptools deprecates the license TOML table; use the PEP 639 SPDX string
	# so the QA elog does not fail CI (LICENSE= carries the licensing)
	sed -i 's/^license = {file = "LICENSE"}$/license = "BSD-3-Clause"/' pyproject.toml || die
	distutils-r1_python_prepare_all
}
