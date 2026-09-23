# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..15} )
PYPI_VERIFY_REPO="https://github.com/neomutt/lsp-tree-sitter"
inherit distutils-r1 pypi

DESCRIPTION="A library to create language servers"
HOMEPAGE="
	https://github.com/neomutt/lsp-tree-sitter
	https://pypi.org/project/lsp-tree-sitter
"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/jq[${PYTHON_USEDEP}]
	dev-python/jsonschema[${PYTHON_USEDEP}]
	dev-python/pygls[${PYTHON_USEDEP}]
	dev-python/tree-sitter[${PYTHON_USEDEP}]
"
