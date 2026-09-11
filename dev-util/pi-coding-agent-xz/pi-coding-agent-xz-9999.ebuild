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
	local arch=$(usex amd64 x64 arm64)

	# Same steps as scripts/build-binaries.sh minus the zip packaging.
	NODE_ENV=production npm run build:offline || die

	cd "${S}/packages/coding-agent" || die
	bun build --compile --minify --bytecode --format=esm \
		--target="bun-linux-${arch}" \
		./dist/bun/cli.js ./src/utils/image-resize-worker.ts \
		--outfile dist/pi || die
	npm run copy-binary-assets || die

	# copy-binary-assets leaves the X11 clipboard helper to build-binaries.sh.
	if use X; then
		mkdir -p "dist/native/linux/prebuilds/linux-${arch}" || die
		cp "../tui/native/linux/prebuilds/linux-${arch}/linux-platform-x11.node" \
			"dist/native/linux/prebuilds/linux-${arch}/" || die
		cp ../../LICENSE dist/native/LICENSE || die
	fi

	mv dist/pi dist/pi-native || die
	cat > dist/pi <<-EOF || die
		#!/bin/sh
		exec "\$(dirname "\$(readlink -f "\$0")")/pi-native" "\$@"
	EOF
}

src_install() {
	local dist="${S}/packages/coding-agent/dist"
	insinto /opt/${PN}
	doins "${dist}"/{package.json,README.md,CHANGELOG.md,photon_rs_bg.wasm}
	doins -r "${dist}"/{theme,assets,export-html,docs,examples}
	use X && doins -r "${dist}"/native

	# pi update --self refuses to overwrite the binary when this marker exists.
	touch "${ED}/opt/${PN}/.portage.managed.lock" || die

	exeinto /opt/${PN}
	doexe "${dist}"/{pi,pi-native}

	dosym ../${PN}/pi /opt/bin/$(usex coexist pi-xz pi)
}
