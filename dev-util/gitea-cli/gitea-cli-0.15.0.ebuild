# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion

DESCRIPTION="Command line tool to interact with Gitea"
HOMEPAGE="https://gitea.com/gitea/tea"
SRC_URI="https://gitea.com/gitea/tea/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-vendor.tar.xz -> ${P}-deps.tar.xz"
S="${WORKDIR}/tea"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

BDEPEND=">=dev-lang/go-1.26"

src_compile() {
	ego build -trimpath \
		-ldflags "-X gitea.dev/tea/modules/version.Version=${PV} -s -w" \
		-o bin/tea .
}

src_test() {
	ego test ./...
}

src_install() {
	dobin bin/tea

	./bin/tea completion bash > tea.bash || die
	dobashcomp tea.bash

	./bin/tea completion zsh > _tea || die
	dozshcomp _tea

	./bin/tea completion fish > tea.fish || die
	dofishcomp tea.fish
}
