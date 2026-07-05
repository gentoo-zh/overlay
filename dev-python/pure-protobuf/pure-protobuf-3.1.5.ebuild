# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry-core
PYTHON_COMPAT=( python3_{13..14} )

inherit distutils-r1 pypi

DESCRIPTION="A pure python implementation of google protobuf"
HOMEPAGE="https://github.com/eigenein/protobuf"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/typing-extensions-4.4.0[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
"

src_prepare() {
	# Patch backend to use poetry-core directly, avoiding poetry-dynamic-versioning dependency.
	sed -i \
		-e 's:poetry_dynamic_versioning.backend:poetry.core.masonry.api:' \
		-e '/"poetry-dynamic-versioning"/d' \
		pyproject.toml || die
	distutils-r1_src_prepare
}

python_test() {
	local -x PYTHONPATH="${BUILD_DIR}/install$(python_get_sitedir)"
	"${EPYTHON}" -c "from pure_protobuf.annotations import Field; from pure_protobuf.message import BaseMessage" \
		|| die "Import check failed with ${EPYTHON}"
}
