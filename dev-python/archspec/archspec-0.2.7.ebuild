# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="A library for detecting, labeling, and reasoning about microarchitectures"
HOMEPAGE="https://github.com/archspec/archspec"

CPUID="5b381ed2af05ad9ead46a136b43c2f7021bd44bb"

SRC_URI="
	https://github.com/archspec/archspec/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/archspec/archspec-json/archive/v${PV}.tar.gz -> ${P}-json.tar.gz
	https://github.com/archspec/cpuid/archive/${CPUID}.tar.gz -> ${P}-cpuid.tar.gz"

LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_unpack() {
	default
	mv -u "${PN}-json-${PV}/cpu/" "${S}/${PN}/json" || die
	rm -r "${S}/${PN}/vendor/cpuid" || die
	mv -u "cpuid-${CPUID}" "${S}/${PN}/vendor/cpuid" || die
}
