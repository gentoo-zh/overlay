# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open-source coding-agent CLI for cloud and local LLM providers"
HOMEPAGE="https://github.com/Twigpine/openclaude"
# Scoped npm package: @twigpine/openclaude
# Bundled dist/cli.mjs still has dynamic imports requiring node_modules at runtime.
# Vendor tarball with production node_modules is hosted on gentoo-zh-drafts.
SRC_URI="
	https://registry.npmjs.org/@twigpine/${PN}/-/${P}.tgz
	https://github.com/gentoo-zh-drafts/openclaude/releases/download/v${PV}/${P}-node_modules.tar.gz
"

# The vendored node_modules only carries the linux-x64 native packages;
# fetch their arm64 counterparts from the npm registry.
ARM64_PACKAGES=(
	@img/sharp-libvips-linux-arm64:1.2.4
	@img/sharp-linux-arm64:0.34.5
	@oxc-parser/binding-linux-arm64-gnu:0.153.0
	@oxc-resolver/binding-linux-arm64-gnu:11.24.2
	@vscode/ripgrep-linux-arm64:1.18.0
)
for _p in "${ARM64_PACKAGES[@]}"; do
	_n=${_p%:*}
	_v=${_p##*:}
	_f=${_n#@}
	SRC_URI+="
		arm64? (
			https://registry.npmjs.org/${_n}/-/${_n##*/}-${_v}.tgz
				-> ${P}-${_f//\//-}-${_v}.tgz
		)
	"
done
unset _p _n _v _f

S="${WORKDIR}/package"

LICENSE="openclaude"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="
	usr/lib/node_modules/@twigpine/${PN}/node_modules/*
	usr/lib64/node_modules/@twigpine/${PN}/node_modules/*
"

RDEPEND="
	>=net-libs/nodejs-22
	dev-vcs/git
	sys-apps/ripgrep
"

src_unpack() {
	unpack ${P}.tgz ${P}-node_modules.tar.gz

	if use arm64; then
		local p n v f
		for p in "${ARM64_PACKAGES[@]}"; do
			n=${p%:*}
			v=${p##*:}
			f=${n#@}
			rm -rf "${S}/node_modules/${n/arm64/x64}" || die
			mkdir -p "${S}/node_modules/${n}" || die
			tar -xzf "${DISTDIR}/${P}-${f//\//-}-${v}.tgz" --strip-components=1 \
				-C "${S}/node_modules/${n}" || die
		done
	fi
}

src_install() {
	local install_dir="/usr/$(get_libdir)/node_modules/@twigpine/${PN}"
	local arch=x64
	use arm64 && arch=arm64

	insinto "${install_dir#${EPREFIX}}"
	doins -r "${S}"/*

	# Explicitly set execute permission only on files known to need it.
	# If openclaude fails at runtime with EACCES, add the missing path here.
	fperms +x "${install_dir}/bin/openclaude"
	fperms +x "${install_dir}/node_modules/@vscode/ripgrep-linux-${arch}/bin/rg"
	fperms +x "${install_dir}/node_modules/@anthropic-ai/sandbox-runtime/dist/vendor/seccomp/${arch}/apply-seccomp"
	fperms +x "${install_dir}/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/${arch}/apply-seccomp"

	dosym "../$(get_libdir)/node_modules/@twigpine/${PN}/bin/openclaude" "/usr/bin/openclaude"
}
