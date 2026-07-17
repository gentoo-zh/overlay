# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#VIM_PLUGIN_VIM_VERSION="7.0"
inherit git-r3 vim-plugin

DESCRIPTION="vim plugin: The ultimate vim statusline utility"
HOMEPAGE="https://www.vim.org/scripts/script.php?script_id=3881"
EGIT_REPO_URI="https://github.com/Lokaltog/vim-powerline.git"
EGIT_BRANCH=develop
LICENSE="CC-BY-SA-3.0"

VIM_PLUGIN_HELPFILES="Powerline"

src_prepare() {
	rm -r .git* || die
	default
}
