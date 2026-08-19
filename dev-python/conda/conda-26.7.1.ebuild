# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1

DESCRIPTION="OS-agnostic, system-level binary package manager and ecosystem"
HOMEPAGE="https://docs.conda.io/"
SRC_URI="https://github.com/conda/conda/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-vcs/git
		$(python_gen_cond_dep '
		dev-python/archspec[${PYTHON_USEDEP}]
		dev-python/boltons[${PYTHON_USEDEP}]
		dev-python/charset-normalizer[${PYTHON_USEDEP}]
		dev-python/conda-package-handling[${PYTHON_USEDEP}]
		dev-python/conda-package-streaming[${PYTHON_USEDEP}]
		dev-python/distro[${PYTHON_USEDEP}]
		dev-python/frozendict[${PYTHON_USEDEP}]
		dev-python/jsonpatch[${PYTHON_USEDEP}]
		dev-python/menuinst[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/platformdirs[${PYTHON_USEDEP}]
		dev-python/pluggy[${PYTHON_USEDEP}]
		dev-python/pyopenssl[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/ruamel-yaml[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/toolz[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/truststore[${PYTHON_USEDEP}]
		dev-python/msgpack[${PYTHON_USEDEP}]
		dev-python/pycosat[${PYTHON_USEDEP}]')
		$(python_gen_cond_dep '
		dev-python/backports-zstd[${PYTHON_USEDEP}]' python3_12 python3_13)
		mamba? ( dev-python/conda-libmamba-solver[${PYTHON_SINGLE_USEDEP}] )"
RDEPEND="${DEPEND}"

IUSE="+user +mamba"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

PATCHES=(
	"${FILESDIR}/conda-23.11.0-remove-tests.patch"
)

python_prepare_all() {
	echo ${PV} > conda/.version || die
	distutils-r1_python_prepare_all
}

python_install() {
	distutils-r1_python_install
	sed -i 's/conda\.cli\.main_pip/conda.cli.main/' "${ED}/usr/bin/conda"
	# no need for Python Byte compiling and multi python slot, please do not use python_doscript
	# this ebuild just use one stable python target
}

python_install_all() {
	echo "$(cat "${FILESDIR}/condarc.default")" >> "${T}/condarc" || die
	if use user ; then
		echo "$(cat "${FILESDIR}/condarc.user")" >> "${T}/condarc" || die
	fi
	# conda use libmamba as default solver
	if ! use mamba; then
		echo "$(cat "${FILESDIR}/condarc.classic")" >> "${T}/condarc" || die
	fi
	insinto /etc/conda
	doins "${T}/condarc"
}

pkg_postinst() {
	elog "Initialize conda for shell interaction, "
	elog "run 'conda init shells' "
	elog "Currently compatible shells are {bash, fish, powershell, tcsh, xonsh, zsh}"
	elog "base environment is managed by portage, do not use conda in base env!"
}
