# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Full-featured Telegram client library for Python"
HOMEPAGE="https://codeberg.org/Lonami/Telethon"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/pyaes[${PYTHON_USEDEP}]
	dev-python/rsa[${PYTHON_USEDEP}]
"

# tests need a real Telegram account and network access
RESTRICT="test"

src_prepare() {
	# the PyPI sdist omits hatch_build.py referenced by the custom build hook
	sed -i '/\[tool.hatch.build.hooks.custom\]/d' pyproject.toml || die
	distutils-r1_src_prepare
}
