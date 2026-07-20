# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion

DESCRIPTION="The glamourous AI coding agent for your favourite terminal 💘"
HOMEPAGE="https://github.com/charmbracelet/crush"
SRC_URI="
	https://github.com/charmbracelet/crush/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/crush/releases/download/v${PV}/${P}-vendor.tar.xz
"
S="${WORKDIR}"/${P}

# https://fsl.software/FSL-1.1-MIT.template.md
LICENSE="FSL-1.1-MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

BDEPEND=">=dev-lang/go-1.25.5"

src_compile() {
	local ldflags="\
		-X github.com/charmbracelet/crush/internal/version.Version=${PV}"
	ego build -o ${PN} -trimpath -ldflags "${ldflags}"
}

src_install() {
	# generate shell completion scripts
	for sh in bash fish zsh; do
	        ./${PN} completion ${sh} > "completion.${sh}"
	done

	dobin ${PN}

	newbashcomp completion.bash "${PN}"
	newfishcomp completion.fish "${PN}".fish
	newzshcomp completion.zsh _"${PN}"
}
