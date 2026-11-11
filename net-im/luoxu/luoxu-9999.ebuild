# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
inherit cargo git-r3 distutils-r1 systemd

EGIT_REPO_URI="https://github.com/lilydjwg/luoxu.git"

DESCRIPTION="A Telegram userbot to index Chinese and Japanese group contents"
HOMEPAGE="https://github.com/lilydjwg/luoxu"
LICENSE="GPL-3"
SLOT="0"
DEPEND=">=app-i18n/opencc-1.4.0:="
RDEPEND="
	${DEPEND}
	acct-group/luoxu
	acct-user/luoxu
	dev-python/aiohttp[${PYTHON_USEDEP}]
	dev-python/asyncpg[${PYTHON_USEDEP}]
	dev-python/telethon[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
	virtual/pkgconfig
"

# needs a Telegram account and a configured PostgreSQL database
RESTRICT="test"

PATCHES=(
	# replace the unstable Iterator::intersperse with plain loop code
	# so the extension builds on stable rustc
	"${FILESDIR}"/${PN}-intersperse-stable.patch
)

src_unpack() {
	git-r3_src_unpack
	# the Rust extension lives in a subdirectory
	cd "${S}/querytrans" || die
	cargo_live_src_unpack
}

src_prepare() {
	# PEP 639: license as a TOML table is deprecated and the setuptools
	# warning lands in the elog; use the SPDX string form instead
	sed -i -e 's|^license = { file = "LICENSE" }$|license = "GPL-3.0-only"|' pyproject.toml || die

	# pyproject declares a dynamic version without a source; pin it for the live ebuild
	sed -i -e '/^dynamic = /d' -e '/^name = "luoxu"$/a version = "9999"' pyproject.toml || die

	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install

	dodoc config.toml.example dbsetup.sql

	insinto /etc/luoxu
	doins config.toml.example

	systemd_dounit "${FILESDIR}"/luoxu.service
	newinitd "${FILESDIR}"/luoxu.initd luoxu
	newconfd "${FILESDIR}"/luoxu.confd luoxu
}

pkg_postinst() {
	elog "luoxu is a userbot that indexes Telegram groups with your own account;"
	elog "upstream warns that userbot usage carries a ban risk."
	elog ""
	elog "Setup: create a database with the pgroonga extension, import dbsetup.sql"
	elog "(shipped in /usr/share/doc/${PF}), then create /etc/luoxu/config.toml"
	elog "from config.toml.example and complete the one-time Telegram login for"
	elog "the service user (the session file is created by any Telethon login, e.g."
	elog "with python3 -m luoxu.ls_dialogs from an interactive shell)."
	elog "For the group-list helper and further details see the upstream README."
}
