# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
PYPI_VERIFY_REPO=https://github.com/outloudvi/mw2fcitx

inherit distutils-r1 pypi

DESCRIPTION="Build fcitx5 libraries from MediaWiki sites"
HOMEPAGE="
	https://github.com/outloudvi/mw2fcitx
	https://pypi.org/project/mw2fcitx
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=app-i18n/opencc-1.1.9[python(-),${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/pypinyin-0.54.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-6.0.2[${PYTHON_USEDEP}]
		>=dev-python/requests-2.32.4[${PYTHON_USEDEP}]
	')
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
