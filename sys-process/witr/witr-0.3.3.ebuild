# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion

DESCRIPTION="Trace any process, port, container, or file back to what started it"
HOMEPAGE="https://github.com/pranshuparmar/witr"
SRC_URI="https://github.com/pranshuparmar/witr/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
# vendored dependencies in the upstream tarball
LICENSE+=" BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.25.0"

src_compile() {
	ego build -trimpath -o bin/witr ./cmd/witr
}

src_test() {
	ego test ./...
}

src_install() {
	dobin bin/witr
	doman docs/cli/witr.1
	einstalldocs

	./bin/witr completion bash > witr.bash || die
	newbashcomp witr.bash witr

	./bin/witr completion zsh > _witr || die
	dozshcomp _witr

	./bin/witr completion fish > witr.fish || die
	dofishcomp witr.fish
}
