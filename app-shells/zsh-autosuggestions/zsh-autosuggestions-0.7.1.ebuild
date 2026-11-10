# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit readme.gentoo-r1

DESCRIPTION="Fish-like autosuggestions for zsh"
HOMEPAGE="https://github.com/zsh-users/zsh-autosuggestions"
SRC_URI="https://github.com/zsh-users/zsh-autosuggestions/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# spec/spec_helper.rb requires rspec-wait and pry-byebug, which ::gentoo lacks
RESTRICT="test"

RDEPEND="app-shells/zsh"

DISABLE_AUTOFORMATTING="true"

DOC_CONTENTS="\
In order to use ${CATEGORY}/${PN}, add
\`source /usr/share/zsh/site-functions/zsh-autosuggestions.zsh\`
to your ~/.zshrc"

src_install() {
	insinto /usr/share/zsh/site-functions
	doins zsh-autosuggestions.zsh

	einstalldocs
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
