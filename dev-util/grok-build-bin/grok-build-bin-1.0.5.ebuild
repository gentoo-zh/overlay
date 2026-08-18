# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="Terminal-based AI coding agent by SpaceXAI"
HOMEPAGE="https://x.ai/cli https://github.com/xai-org/grok-build"
MY_COMMIT="eb267feff13129e568df38fb6fdf0ceb65f735d6"
SRC_URI="
	amd64? ( https://x.ai/cli/grok-${PV}-linux-x86_64 -> ${P}-amd64 )
	https://raw.githubusercontent.com/xai-org/grok-build/${MY_COMMIT}/LICENSE
		-> ${P}-LICENSE
	https://raw.githubusercontent.com/xai-org/grok-build/${MY_COMMIT}/THIRD-PARTY-NOTICES
		-> ${P}-THIRD-PARTY-NOTICES
"

S="${WORKDIR}"

LICENSE="
	Apache-2.0 BSD BSD-2 Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 ISC MIT MIT-0
	MPL-2.0 Unicode-3.0 Unicode-DFS-2016 ZLIB
"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/grok"

src_unpack() {
	cp "${DISTDIR}/${P}-amd64" grok || die
	chmod +x grok || die
}

src_compile() {
	export GROK_DISABLE_AUTOUPDATER=1

	./grok completions bash > grok.bash || die
	./grok completions fish > grok.fish || die
	./grok completions zsh > _grok || die
}

src_install() {
	dobin grok

	newbashcomp grok.bash grok
	dofishcomp grok.fish
	dozshcomp _grok

	newdoc "${DISTDIR}/${P}-LICENSE" LICENSE
	newdoc "${DISTDIR}/${P}-THIRD-PARTY-NOTICES" THIRD-PARTY-NOTICES

	insinto /etc/grok
	doins "${FILESDIR}/requirements.toml"
}
