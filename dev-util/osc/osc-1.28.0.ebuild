# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )
inherit distutils-r1

DESCRIPTION="The Command Line Interface to work with an Open Build Service"
HOMEPAGE="https://github.com/openSUSE/osc"
SRC_URI="https://github.com/openSUSE/osc/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

DEPEND="
	dev-python/cryptography
	dev-python/ruamel-yaml
	dev-python/urllib3
"
RDEPEND="
	${DEPEND}
	dev-util/diffstat
"
BDEPEND="
	dev-python/argparse-manpage
	dev-python/cryptography
	dev-python/urllib3
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )
"

PATCHES=( "${FILESDIR}/${PN}-1.21.0-setuptools.patch" )

EPYTEST_DESELECT=(
	# AssertionError: Lists differ: ['/usr/lib/osc-plugins', '/usr/local/lib/o[53 chars]ins'] != []
	tests/test_doc_plugins.py::TestPopProjectPackageFromArgs::test_plugin_locations
	# PermissionError: [Errno 13] Permission denied: '/var/lib/portage/home/.local'
	tests/test_vc.py::TestVC::test_vc_export_env_api_call
	tests/test_vc.py::TestVC::test_vc_export_env_conf_email
	tests/test_vc.py::TestVC::test_vc_export_env_conf_realname
)

EPYTEST_PLUGINS=()

distutils_enable_tests pytest
