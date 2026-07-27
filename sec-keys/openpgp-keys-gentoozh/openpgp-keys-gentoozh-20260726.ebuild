# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# The key is published only on the project's own mirror and on no public
# keyserver, hence the manual location and the explicit SRC_URI below.
# The eclass checks the fingerprint during src_compile.
SEC_KEYS_VALIDPGPKEYS=(
	'6A0726AF1476A2F382C6AC6638A0234EC16AD42E:gentoozh:manual'
)

inherit sec-keys

DESCRIPTION="OpenPGP keys used to sign gentoo-zh binary packages"
HOMEPAGE="https://distfiles.gentoozh.org/"
SRC_URI="https://distfiles.gentoozh.org/gentoo-zh-binhost.asc -> ${P}.asc"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
