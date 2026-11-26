# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=(python3_{13..14})

inherit distutils-r1 optfeature

DESCRIPTION="Modern Text User Interface framework"
HOMEPAGE="
	https://textual.textualize.io/
	https://github.com/Textualize/textual
	https://pypi.org/project/textual/
"
SRC_URI="https://github.com/Textualize/textual/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/markdown-it-py-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-3.6.0[${PYTHON_USEDEP}]
	<dev-python/platformdirs-5[${PYTHON_USEDEP}]
	>=dev-python/rich-14.2.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.4.0[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
"

RESTRICT="test"

declare -A SYNTAX_LANGS=(
	["bash"]="Bash"
	["c"]="C"
	# TODO Missing keyword for ~arm64 in ::gentoo
	#["cmake"]="CMake"
	["cpp"]="C++"
	["html"]="HTML"
	["javascript"]="JavaScript"
	["json"]="JSON"
	["lua"]="Lua"
	# TODO No Python bindings in ::gentoo
	#["markdown"]="Markdown"
	["python"]="Python"
	# TODO Missing keyword for ~arm64 in ::gentoo
	#["ruby"]="Ruby"
	["rust"]="Rust"
	# TODO Many other (common) languages are neither in ::gentoo nor ::guru
)

DOCS+=({CHANGELOG,README}.md)

pkg_postinst() {
	optfeature_header "Install additional packages for syntax highlighting:"

	local lang
	for lang in "${!SYNTAX_LANGS[@]}"; do
		optfeature "${SYNTAX_LANGS[${lang}]}" "dev-libs/tree-sitter-${lang}[python]"
	done
}
