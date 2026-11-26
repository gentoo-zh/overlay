# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=(python3_{13..14})

inherit distutils-r1 xdg

DESCRIPTION="Interactive TUI for systemd units"
HOMEPAGE="https://github.com/kainctl/isd"
SRC_URI="https://github.com/kainctl/isd/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test"

RDEPEND="
	>=dev-python/pfzy-0.3.4[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.10.4[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.7.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.1[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	>=dev-python/textual-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/xdg-base-dirs-6.0.0[${PYTHON_USEDEP}]
	sys-apps/systemd
	x11-themes/hicolor-icon-theme
"

DOCS=(README.md)
