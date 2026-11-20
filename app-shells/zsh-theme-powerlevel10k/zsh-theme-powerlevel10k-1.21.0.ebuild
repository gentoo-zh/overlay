# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature

MY_PN="${PN##zsh-theme-}"

DESCRIPTION="Theme for Zsh that emphasizes speed, flexibility and out-of-the-box experience"
HOMEPAGE="https://github.com/romkatv/powerlevel10k"
SRC_URI="https://github.com/romkatv/powerlevel10k/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="app-shells/zsh
		app-shells/gitstatus[zsh-completion]"
RDEPEND="${DEPEND}"

src_prepare() {
	sed -i Makefile -e '/gitstatus/d' || die

	default
}

src_compile() {
	emake pkg
}

src_install() {
	dodoc {README,font}.md

	insinto "/usr/share/zsh/site-functions/${MY_PN}"

	doins -r config/
	doins -r internal/
	doins prompt_*_setup
	doins powerlevel*.zsh-theme{,.zwc}

	dosym ../../../gitstatus \
		"/usr/share/zsh/site-functions/${MY_PN}/gitstatus"
}

pkg_postinst() {
	elog "To use this theme, source /usr/share/zsh/site-functions/powerlevel10k/powerlevel10k.zsh-theme in your ~/.zshrc"

	optfeature_header "Install one of these for Nerd Font glyphs, or provide a patched font yourself:"
	optfeature "the full choice of style options" \
		media-fonts/nerd-fonts media-fonts/sarasa-term-sc-nerd \
		media-fonts/symbols-nerd-font
}
