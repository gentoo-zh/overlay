# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="A terminal-based coding agent with multi-model support (xz-dev downstream fork)"
HOMEPAGE="https://github.com/xz-dev/pi"
EGIT_REPO_URI="https://github.com/xz-dev/pi.git"

LICENSE="MIT"
SLOT="0"
IUSE="X coexist"
# Stripping would remove the payload bun appends to the compiled executable.
RESTRICT="strip"

BDEPEND="
	~dev-lang/bun-bin-1.4.2
	>=net-libs/nodejs-22.19
"
RDEPEND="
	!coexist? ( !dev-util/pi-coding-agent-bin )
	sys-apps/fd
	sys-apps/ripgrep
	X? ( x11-libs/libxcb )
"

src_unpack() {
	git-r3_src_unpack

	# npm and the models.dev fetch need network, which only src_unpack has.
	cd "${S}" || die
	npm ci --ignore-scripts || die
	npm run hydrate:model-data || die
}

src_compile() {
	local target=$(usex amd64 linux-x64-gnu-baseline linux-arm64-gnu)
	local myargs=()
	use X || myargs+=( --without-x11 )

	# Use the release build script so the embedded resources and entrypoint
	# always match the published single executables.
	bash scripts/build-binaries.sh --skip-install --offline-model-data \
		--platform "${target}" --out "${T}/out" "${myargs[@]}" || die
	mv "${T}/out/pi-${target}" "${T}/pi" || die
}

src_install() {
	exeinto /opt/${PN}
	doexe "${T}/pi"

	# pi update --self refuses to replace the binary when this marker exists.
	touch "${ED}/opt/${PN}/.portage.managed.lock" || die

	dosym ../${PN}/pi /opt/bin/$(usex coexist pi-xz pi)
}
