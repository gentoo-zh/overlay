# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYPI_VERIFY_REPO=https://github.com/srstevenson/xdg-base-dirs
PYTHON_COMPAT=( python3_{11..15} )

inherit distutils-r1 pypi

DESCRIPTION="Variables defined by the XDG Base Directory Specification"
HOMEPAGE="
	https://github.com/srstevenson/xdg-base-dirs
	https://pypi.org/project/xdg-base-dirs/
"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
