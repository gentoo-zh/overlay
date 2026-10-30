# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# npm versions use -rc.N; Gentoo PV uses _rcN.
MY_PV="$(ver_rs 3 - 4 .)"

DESCRIPTION="DeepSeek Harness: an agent harness by DeepSeek AI (dsh CLI)"
HOMEPAGE="https://github.com/deepseek-ai/deepseek-harness"

SRC_URI="
	https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${MY_PV}.tgz
		-> ${PN}-${MY_PV}.tgz
	https://github.com/gentoo-zh-drafts/deepseek-harness/releases/download/v${MY_PV}/${PN}-${MY_PV}-node_modules.tar.xz
"

# The vendored node_modules only carries the linux-x64 native packages;
# fetch their arm64 counterparts from the npm registry.
ARM64_PACKAGES=(
	@deepseek-ai/node-addon-system-linux-arm64:0.1.2
	@img/sharp-libvips-linux-arm64:1.3.4
	@img/sharp-linux-arm64:0.35.5
	@koromix/koffi-linux-arm64:3.1.1
	@vscode/ripgrep-linux-arm64:1.18.0
	node-addon-require-builtin-linux-arm64-gnu:0.1.9
	sherpa-onnx-linux-arm64:1.13.8
)
for _p in "${ARM64_PACKAGES[@]}"; do
	_n=${_p%:*}
	_v=${_p##*:}
	_f=${_n#@}
	SRC_URI+="
		arm64? (
			https://registry.npmjs.org/${_n}/-/${_n##*/}-${_v}.tgz
				-> ${PN}-${MY_PV}-${_f//\//-}-${_v}.tgz
		)
	"
done
unset _p _n _v _f

S="${WORKDIR}/package"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

# Prebuilt native addons ship from the npm platform packages.
QA_PREBUILT="
	usr/lib/node_modules/@deepseek-ai/dsh/node_modules/*
	usr/lib64/node_modules/@deepseek-ai/dsh/node_modules/*
"

RDEPEND=">=net-libs/nodejs-22.19"

src_unpack() {
	unpack ${PN}-${MY_PV}.tgz ${PN}-${MY_PV}-node_modules.tar.xz

	if use arm64; then
		local p n v f
		for p in "${ARM64_PACKAGES[@]}"; do
			n=${p%:*}
			v=${p##*:}
			f=${n#@}
			rm -rf "${S}/node_modules/${n/arm64/x64}" || die
			mkdir -p "${S}/node_modules/${n}" || die
			tar -xzf "${DISTDIR}/${PN}-${MY_PV}-${f//\//-}-${v}.tgz" \
				--strip-components=1 -C "${S}/node_modules/${n}" || die
		done
	fi
}

src_prepare() {
	default
	local arch=x64 other=arm64
	use arm64 && { arch=arm64; other=x64; }
	# Keep only the node-pty prebuilds for this arch.
	rm -rf "${S}"/node_modules/node-pty/prebuilds/win32-* \
		"${S}"/node_modules/node-pty/prebuilds/darwin-* \
		"${S}"/node_modules/node-pty/prebuilds/linux-${other} \
		"${S}"/node_modules/node-pty/third_party/conpty || die
	# koffi-linux-* and node-addon-system-linux-* ship glibc and musl
	# builds; keep the active libc.
	if use elibc_musl; then
		rm -rf "${S}"/node_modules/@koromix/koffi-linux-${arch}/linux_${arch} \
			"${S}"/node_modules/@deepseek-ai/node-addon-system-linux-${arch}/bin/glibc || die
	else
		rm -rf "${S}"/node_modules/@koromix/koffi-linux-${arch}/musl_${arch} \
			"${S}"/node_modules/@deepseek-ai/node-addon-system-linux-${arch}/bin/musl || die
	fi
}

src_install() {
	local install_dir="/usr/$(get_libdir)/node_modules/@deepseek-ai/dsh"

	insinto "${install_dir}"
	doins -r "${S}"/*

	fperms +x "${install_dir}/lib/bin.js"

	dosym -r "${install_dir}/lib/bin.js" /usr/bin/dsh
}

pkg_postinst() {
	elog "Run 'dsh web' (browser UI) or 'dsh --profile headless \"task\"' (one-shot); see 'dsh --help' for all profiles."
}
