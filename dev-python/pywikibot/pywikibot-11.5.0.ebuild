# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit pypi distutils-r1

DESCRIPTION="To interact with MediaWiki API (for example Wikipedia, Wikimedia Commons)"
HOMEPAGE="
	https://www.mediawiki.org/wiki/Manual:Pywikibot
	https://github.com/wikimedia/pywikibot
	https://pypi.org/project/pywikibot
"

LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	>=dev-python/packaging-25.0[${PYTHON_USEDEP}]
	>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
"
RDEPEND="
	>=dev-python/mwparserfromhell-0.7.2[${PYTHON_USEDEP}]
	>=dev-python/packaging-25.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.32.3[${PYTHON_USEDEP}]
"
