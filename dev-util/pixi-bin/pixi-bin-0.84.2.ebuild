# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion toolchain-funcs

DESCRIPTION="A package management and workflow tool (prebuilt binary)"
HOMEPAGE="
	https://pixi.prefix.dev/
	https://github.com/prefix-dev/pixi/
"
BASE_URI="https://github.com/prefix-dev/pixi/releases/download/v${PV}"
SRC_URI="
	amd64? ( ${BASE_URI}/pixi-x86_64-unknown-linux-musl.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( ${BASE_URI}/pixi-aarch64-unknown-linux-musl.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="BSD"
# Dependent crate licenses
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB BZIP2
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	!dev-util/pixi
	app-misc/ca-certificates
"

QA_PREBUILT="usr/bin/pixi"

src_install() {
	dobin pixi

	insinto /etc/pixi
	newins - config.toml <<-EOF
		# Use system certificates.
		tls-root-certs = "system"
	EOF

	if ! tc-is-cross-compiler; then
		newbashcomp - pixi < <("${ED}"/usr/bin/pixi completion --shell=bash)
		newfishcomp - pixi.fish < <("${ED}"/usr/bin/pixi completion --shell=fish)
		newzshcomp - _pixi < <("${ED}"/usr/bin/pixi completion --shell=zsh)
	fi
}
