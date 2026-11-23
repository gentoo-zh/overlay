# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion

DESCRIPTION="Manage your dotfiles across multiple diverse machines, securely"
HOMEPAGE="https://www.chezmoi.io https://github.com/twpayne/chezmoi"
SRC_URI="https://github.com/twpayne/chezmoi/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/gentoo-zh-drafts/chezmoi/releases/download/v${PV}/${P}-vendor.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

RDEPEND="dev-vcs/git"
RDEPEND+=" !app-admin/chezmoi-bin"
BDEPEND=">=dev-lang/go-1.26.0"

src_compile() {
	local ldflags="\
		-X main.version=${PV} \
		-X main.date=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	ego build -trimpath -ldflags "${ldflags}"
}

src_install() {
	dobin chezmoi
	newbashcomp completions/chezmoi-completion.bash chezmoi
	newzshcomp completions/chezmoi.zsh _chezmoi
}
